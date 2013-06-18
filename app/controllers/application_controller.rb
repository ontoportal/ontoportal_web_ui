require 'uri'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'net/ftp'
require 'json'
require 'cgi'
require 'rest-client'
require 'ontologies_api_client'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# Custom 404 handling
class Error404 < StandardError; end

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  REST_URI = "http://#{$REST_DOMAIN}"
  API_KEY = $API_KEY

  # TODO: Evalute whether the ontologies hash could be in a REDIS key:value store.
  # If so, this could avoid all the repetitive API requests for basic ontology details.
  ONTOLOGIES = {}  # see get_ontology_details method.

  if !$EMAIL_EXCEPTIONS.nil? && $EMAIL_EXCEPTIONS == true
    include ExceptionNotifiable
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ba3e1ab68d3ab8bd1a1e109dfad93d30'

  before_filter  :preload_models, :set_global_thread_values, :domain_ontology_set

  # Needed for memcache to understand the models in storage
  def preload_models()
    Note
    NodeWrapper
    NodeLabel
    Annotation
    Mapping
    MappingPage
    MarginNote
    OntologyWrapper
    OntologyMetricsWrapper
    UserWrapper
    Groups
    SearchResults
  end

  def set_global_thread_values
    Thread.current[:session] = session
    Thread.current[:request] = request
  end

  def domain_ontology_set
    # TODO_REV: Custom ontology sets
    # if !$ENABLE_SLICES.nil? && $ENABLE_SLICES == true
    #   host = request.host
    #   host_parts = host.split(".")
    #   subdomain = host_parts[0]

    #   groups = DataAccess.getGroupsWithOntologies
    #   groups_hash = {}
    #   groups.group_list.each do |group_id, group|
    #     groups_hash[group[:acronym].downcase.gsub(" ", "-")] = { :name => group[:name], :ontologies => group[:ontologies] }
    #   end
    #   $ONTOLOGY_SLICES.merge!(groups_hash)

    #   @subdomain_filter = { :active => false, :name => "", :acronym => "" }

    #   # Set custom ontologies if we're on a subdomain that has them
    #   # Else, make sure user ontologies are set appropriately
    #   if $ONTOLOGY_SLICES.include?(subdomain)
    #     session[:user_ontologies] = { :virtual_ids => Set.new($ONTOLOGY_SLICES[subdomain][:ontologies]), :ontologies => nil }
    #     @subdomain_filter[:active] = true
    #     @subdomain_filter[:name] = $ONTOLOGY_SLICES[subdomain][:name]
    #     @subdomain_filter[:acronym] = subdomain
    #   elsif session[:user]
    #     session[:user_ontologies] = user_ontologies(session[:user])
    #   else
    #     session[:user_ontologies] = nil
    #   end
    # else
      @subdomain_filter = { :active => false, :name => "", :acronym => "" }
    # end
  end

  def user_ontologies(user)
    custom_ontologies = CustomOntologies.find(:first, :conditions => ["user_id = ?", user.id])
    if custom_ontologies.nil? || custom_ontologies.ontologies.empty?
      return nil
    else
      return { :virtual_ids => Set.new(custom_ontologies.ontologies), :ontologies => nil }
    end
  end

  def anonymous_user
    user = DataAccess.getUser($ANONYMOUS_USER)
    user ||= User.new({"id" => 0})
  end

  # Custom 404 handling
  rescue_from Error404, :with => :render_404

  def render_404
    respond_to do |type|
      #type.html { render :template => "errors/error_404", :status => 404, :layout => 'error' }
      type.all { render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 }
    end
    true
  end

  NOTIFICATION_TYPES = { :notes => "CREATE_NOTE_NOTIFICATION", :all => "ALL_NOTIFICATION" }

  def to_param(name) # Paramaterizes URLs without encoding
    unless name.nil?
      name.to_s.gsub(' ',"_")
    end
  end

  def undo_param(name) #Undo Paramaterization
    unless name.nil?
      name.to_s.gsub('_'," ")
    end
  end

  def remote_file_exists?(url)
    begin
      url = URI.parse(url)

      if url.kind_of?(URI::FTP)
        check = check_ftp_file(url)
      else
        check = check_http_file(url)
      end

    rescue Exception => e
      return false
    end

    check
  end

  def check_http_file(url)
    session = Net::HTTP.new(url.host, url.port)
    session.use_ssl = true if url.port == 443
    session.start do |http|
      response_valid = http.head(url.request_uri).code.to_i < 400
      return response_valid
    end
  end

  def check_ftp_file(uri)
    ftp = Net::FTP.new(uri.host, uri.user, uri.password)
    ftp.login
    begin
      file_exists = ftp.size(uri.path) > 0
    rescue Exception => e
      # Check using another method
      path = uri.path.split("/")
      filename = path.pop
      path = path.join("/")
      ftp.chdir(path)
      files = ftp.dir
      # Dumb check, just see if the filename is somewhere in the list
      files.each { |file| return true if file.include?(filename) }
    end
    file_exists
  end

  def redirect_to_browse # Redirect to the browse Ontologies page
    redirect_to "/ontologies"
  end

  def redirect_to_home # Redirect to Home Page
    redirect_to "/"
  end

  def redirect_to_history # Redirects to the correct tab through the history system
    if session[:redirect].nil?
      redirect_to_home
    else
      tab = find_tab(session[:redirect][:ontology])
      session[:redirect]=nil
      redirect_to uri_url(:ontology=>tab.ontology_id,:conceptid=>tab.concept)
    end
  end

  # rack-mini-profiler authorization
  def authorize
    if session[:user] && session[:user].admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  # Verifies if user is logged in
  def authorize_and_redirect
    unless session[:user]
      redirect_to_home
    end
  end

  # Verifies that a user owns an object
  def authorize_owner(id=nil)
    if id.nil?
      id = params[:id].to_i
    end

    id.map! {|i| i.to_i} if id.kind_of?(Array)

    if session[:user].nil?
      redirect_to_home
    else
      if id.kind_of?(Array)
        redirect_to_home if !session[:user].admin? && !id.include?(session[:user].id.to_i)
      else
        redirect_to_home if !session[:user].admin? && !session[:user].id.to_i.eql?(id)
      end
    end
  end

  # generates a new random password
  def newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  # updates the 'history' tab with the current selected concept
  def update_tab(ontology, concept)
    array = session[:ontologies] || []
    found = false
    for item in array
      if item.ontology_id.eql?(ontology.id)
        item.concept=concept
        found=true
      end
    end

    unless found
      array << History.new(ontology.id,ontology.name,concept)
    end

    session[:ontologies]=array
  end

  # Removes a 'history' tab
  def remove_tab(ontology_id)
    array = session[:ontologies]
    array.delete(find_tab(ontology_id))
    session[:ontologies]=array
  end

  # Returns a specific 'history' tab
  def find_tab(ontology_id)
    array = session[:ontologies]
    for item in array
      if item.ontology_id.eql?(ontology_id)
        return item
      end
    end
    return nil
  end

  def check_delete_mapping_permission(mappings)
    delete_mapping_permission = false
    if session[:user]
      delete_mapping_permission = true if session[:user].admin?
      mappings.each do |mapping|
        break if delete_mapping_permission
        delete_mapping_permission = true if session[:user].id.to_i == mapping.user_id
      end
    end

    delete_mapping_permission
  end

  # Notes-related helpers that could be useful elsewhere

  def convert_java_time(time_in_millis)
    time_in_millis.to_i / 1000
  end

  def time_from_java(java_time)
    Time.at(convert_java_time(java_time.to_i))
  end

  def time_formatted_from_java(java_time)
    time_from_java(java_time).strftime("%m/%d/%Y")
  end

  def using_captcha?
    !ENV['USE_RECAPTCHA'].nil? && ENV['USE_RECAPTCHA'] == 'true'
  end

  def get_class(params)
    if !@ontology.flat? && (!params[:conceptid] || params[:conceptid].empty? || params[:conceptid].eql?("root"))
      # get the top level nodes for the root
      @root = LinkedData::Client::Models::Class.new(read_only: true)
      # TODO_REV: Support views? Replace old view call: @ontology.top_level_terms(view)
      root_children = @ontology.explore.roots
      root_children.sort!{|x,y| (x.prefLabel || "").downcase <=> (y.prefLabel || "").downcase}

      @root.children = root_children

      # get the initial concept to display
      @concept = @root.children.first.explore.self(full: true)

      # Some ontologies have "too many children" at their root. These will not process and are handled here.
      raise Error404 if @concept.nil?
    elsif @ontology.flat? && (!params[:conceptid] || params[:conceptid].empty? || params[:conceptid].eql?("root"))
      # TODO_REV: Handle flat ontologies
      # Don't display any terms in the tree
      # @concept = NodeWrapper.new
      # @concept.label = "Please search for a term using the Jump To field above"
      # @concept.id = "bp_fake_root"
      # @concept.fullId = "bp_fake_root"
      # @concept.child_size = 0
      # @concept.properties = {}
      # @concept.version_id = @ontology.id
      # @concept.children = []

      # @tree_concept = TreeNode.new(@concept)

      # @root = TreeNode.new
      # @root.children = [@tree_concept]
    elsif @ontology.flat? && params[:conceptid]
      # TODO_REV: Handle flat ontologies
      # Display only the requested term in the tree
      # @concept = DataAccess.getNode(@ontology.id, params[:conceptid], nil, view)
      # @concept.children = []
      # @concept.child_size = 0
      # @root = TreeNode.new
      # @root.children = [TreeNode.new(@concept)]
    else
      # if the id is coming from a param, use that to get concept
      @concept = @ontology.explore.single_class(params[:conceptid], full: true)
      raise Error404 if @concept.nil?

      # Create the tree
      rootNode = @concept.explore.tree(full: true)

      if rootNode.nil? || rootNode.empty?
        roots = @ontology.explore.roots
        if roots.any? {|c| c.id == @concept.id}
          rootNode = roots
        else
          rootNode = [@concept]
        end
      end

      rootNode.sort!{|x,y| (x.prefLabel || "").downcase <=> (y.prefLabel || "").downcase}

      @root = LinkedData::Client::Models::Class.new(read_only: true)
      @root.children = rootNode
    end
  end



  # DLW: Methods moved from annotator_controller:


  #def get_ontology_names(annotations)
  #  #
  #  # TODO: Get this working when the batch service supports it.
  #  # TODO: This should replace get_ontology_details().
  #  #
  #  # Use batch service to get ontology names
  #  ontList = []
  #  annotations.each do |a|
  #    ont_id = a['annotatedClass']['links']['ontology']
  #    ontList.push({'ontology'=>ont_id})
  #  end
  #  # remove duplicates
  #  ontSet = ontList.to_set # get unique ontology set
  #  ontList = ontSet.to_a   # assume collection requires a list in batch call
  #  # make the batch call
  #  call_params = {'http://data.bioontology.org/metadata/Ontology'=>{'collection'=>ontList, 'include'=>['name']}}
  #  response = get_batch_results(call_params)
  #  ontNames = JSON.parse(response)
  #  # TODO: massage the return values into something simple.
  #end

  def get_ontology_details(ont_uri)
    if ONTOLOGIES.keys.include? ont_uri
      # Use the saved ontology details to avoid repetitive API requests
      ont = ONTOLOGIES[ont_uri]
    else
      begin
        # Additional API request (synchronous)
        ont_details = parse_json(ont_uri)    # parse_json adds APIKEY.
        ont = {}
        ont['uri'] = ont_uri
        ont['ui'] =  ont_details['links']['ui']
                                             #ont['acronym'] = ont_details['acronym']
        ont['name'] = ont_details['name']
        ont['@id'] = ont_details['@id']
        ONTOLOGIES[ont_uri] = ont
      rescue
        return nil
      end
    end
    return ont
  end


  def get_apikey()
    apikey = API_KEY
    if session[:user]
      apikey = session[:user].apikey
    end
    return apikey
  end


  def parse_json(uri)
    uri = URI.parse(uri)
    LOG.add :debug, "Annotator URI: #{uri}"
    begin
      response = open(uri, "Authorization" => "apikey token=#{get_apikey}").read
    rescue Exception => error
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        raise error
      end
    end
    JSON.parse(response)
  end


  def get_batch_results(params)
    uri = "http://stagedata.bioontology.org/batch/?apikey=#{get_apikey}"
    begin
      response = RestClient.post uri, params.to_json, :content_type => :json, :accept => :json
    rescue Exception => error
      LOG.add :debug, "ERROR: annotator batch POST, uri: #{uri}"
      LOG.add :debug, "ERROR: annotator batch POST, params: #{params}"
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        raise error
      end
    end
    response
  end

end
