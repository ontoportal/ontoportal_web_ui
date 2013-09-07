require 'uri'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'net/ftp'
require 'json'
require 'cgi'
require 'rexml/document'
require 'rest-client'
require 'ontologies_api_client'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# Custom 404 handling
class Error404 < StandardError; end

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # Pull configuration parameters for REST connection.
  REST_URI = "http://#{$REST_DOMAIN}"
  API_KEY = $API_KEY

  # Constants used primarily in the resource_index_controller, but also elsewhere.
  RESOURCE_INDEX_URI = REST_URI + "/resource_index"
  RI_ELEMENT_ANNOTATIONS_URI = RESOURCE_INDEX_URI + "/element_annotations"
  RI_ONTOLOGIES_URI = RESOURCE_INDEX_URI + "/ontologies"
  RI_RANKED_ELEMENTS_URI = RESOURCE_INDEX_URI + "/ranked_elements"
  RI_RESOURCES_URI = RESOURCE_INDEX_URI + "/resources"

  if !$EMAIL_EXCEPTIONS.nil? && $EMAIL_EXCEPTIONS == true
    include ExceptionNotifiable
  end

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

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

  def response_errors(error_struct)
    return unless error_struct
    return unless error_struct.respond_to?(:errors)
    errors = {}
    error_struct.errors.each {|e| ""}
    error_struct.errors.each do |error|
      if error.is_a?(Struct)
        errors.merge!(struct_to_hash(error))
      else
        errors[:error] = error
      end
    end
    errors
  end

  def struct_to_hash(struct)
    hash = {}
    struct.members.each do |attr|
      next if [:links, :context].include?(attr)
      if struct[attr].is_a?(Struct)
        hash[attr] = struct_to_hash(struct[attr])
      else
        hash[attr] = struct[attr]
      end
    end
    hash
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

  def redirect_new_api(class_view = false)
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:ontology] = params[:ontology].nil? ? params[:ontologyid] : params[:ontology]

    # Error checking
    if params[:ontology].nil? || params[:id] && params[:ontology].nil?
      @error = "Please provide an ontology id or concept id with an ontology id."
      return
    end

    acronym = BPIDResolver.id_to_acronym(params[:ontology])
    raise Error404 unless acronym

    params_array = []
    params.each do |key,value|
      stop_words = [ "ontology", "controller", "action", "id" ]
      next if stop_words.include?(key.to_s) || value.nil? || value.empty?
      params_array << "#{key}=#{CGI.escape(value)}"
    end
    params_string = (params_array.empty?) ? "" : "&#{params_array.join('&')}"

    if class_view
      redirect_to "/ontologies/#{acronym}?p=terms#{params_string}", :status => :moved_permanently
    else
      redirect_to "/ontologies/#{acronym}#{params_string.empty? ? "" : "?"}#{params_string[1..-1]}", :status => :moved_permanently
  def params_cleanup_new_api
    params = @_params
    if params[:ontology] && params[:ontology].to_i > 0
      params[:ontology] = BPIDResolver.id_to_acronym(params[:ontology])
    end

    if params[:ontology] && params[:conceptid] && !params[:conceptid].start_with?("http")
      params[:conceptid] = BPIDResolver.uri_from_short_id(params[:ontology], params[:conceptid])
    end

    params
  end

  def params_string_for_redirect(params, options = {})
    prefix = options[:prefix] || "?"
    stop_words = options[:stop_words] || ["ontology", "controller", "action", "id"]
    params_array = []
    params.each do |key,value|
      next if stop_words.include?(key.to_s) || value.nil? || value.empty?
      params_array << "#{key}=#{CGI.escape(value)}"
    end
    params_array.empty? ? "" : "#{prefix}#{params_array.join('&')}"
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

  def authorize_admin
    admin = session[:user] && session[:user].admin?
    redirect_to_home unless admin
  end

  def current_user_admin?
    session[:user] && session[:user].admin?
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
      array << History.new(ontology.id, ontology.name, ontology.acronym, concept)
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
    elsif @ontology.flat? && (!params[:conceptid] || params[:conceptid].empty? || params[:conceptid].eql?("root") || params[:conceptid].eql?("bp_fake_root"))
      # Don't display any terms in the tree
      @concept = LinkedData::Client::Models::Class.new
      @concept.prefLabel = "Please search for a term using the Jump To field above"
      @concept.id = "bp_fake_root"
      @concept.child_size = 0
      @concept.properties = {}
      @concept.children = []
      @root = LinkedData::Client::Models::Class.new
      @root.children = [@concept]
    elsif @ontology.flat? && params[:conceptid]
      # Display only the requested term in the tree
      @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
      @concept.children = []
      @concept.child_size = 0
      @root = LinkedData::Client::Models::Class.new
      @root.children = [@concept]
    else
      # if the id is coming from a param, use that to get concept
      @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
      raise Error404 if @concept.nil?

      # Create the tree
      rootNode = @concept.explore.tree #(full: true)

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

  def get_metrics_hash
    metrics_hash = {}
    @metrics = LinkedData::Client::Models::Metrics.all
    @metrics.each {|m| metrics_hash[m.links['ontology']] = m }
    return metrics_hash
  end

  def get_simplified_ontologies_hash()
    ontologies = {}
    begin
      ontology_models = LinkedData::Client::Models::Ontology.all
      ontology_models.each do |o|
        ont = {}
        ont['ui'] =  o.links['ui']
        ont['acronym'] = o.acronym
        ont['name'] = o.name
        ont['@id'] = o.id
        ontologies[o.id] = ont
      end
    rescue
      return nil
    end
    return ontologies
  end

  def get_ontology_details(ont_uri)
    begin
      ont_model = LinkedData::Client::Models::Ontology.find(ont_uri)
      ont = {}
      ont['uri'] = ont_uri
      ont['ui'] =  ont_model.links['ui']
      ont['acronym'] = ont_model.acronym
      ont['name'] = ont_model.name
      ont['@id'] = ont_model.id
    rescue
      return nil
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


  # This method might be defunct, replaced with LinkedData::Client::HTTP.get()
  def parse_json(uri)
    uri = URI.parse(uri)
    LOG.add :debug, "Parse URI: #{uri}"
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
    #uri = "http://stagedata.bioontology.org/batch/?apikey=#{get_apikey}"
    uri = "http://stagedata.bioontology.org/batch"
    begin
      response = RestClient.post uri, params.to_json, :content_type => :json, :accept => :json, :authorization => "apikey token=#{get_apikey}"
    rescue Exception => error
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        LOG.add :debug, "\nERROR: batch POST, uri: #{uri}"
        LOG.add :debug, "\nERROR: batch POST, params: #{params.to_json}"
        LOG.add :debug, "\nERROR: batch POST, error response: #{error.response}"
        raise error
      end
    end
    response
  end


  def get_resource_index_resources
    return LinkedData::Client::HTTP.get(RI_RESOURCES_URI)
  end

  def get_resource_index_ontologies
    return LinkedData::Client::HTTP.get(RI_ONTOLOGIES_URI)
  end

  def get_resource_index_annotation_stats
    ri_statsURL = 'http://rest.bioontology.org/resource_index/statistics/all'
    ri_statsConn = open(ri_statsURL + '?apikey=' + get_apikey)
    doc = REXML::Document.new(ri_statsConn)
    stats = doc.elements["/success/data/statistics"]
    stats_hash = {}
    stats_hash[:total] = stats.elements["aggregatedAnnotations"].get_text.value.strip.to_i
    stats_hash[:direct] = stats.elements["mgrepAnnotations"].get_text.value.strip.to_i
    stats_hash[:reported] = stats.elements["reportedAnnotations"].get_text.value.strip.to_i
    stats_hash[:hierarchy] = stats.elements["isaAnnotations"].get_text.value.strip.to_i
    stats_hash[:mapping] = stats.elements["mappingAnnotations"].get_text.value.strip.to_i
    stats_hash[:expanded] = stats_hash[:direct] + stats_hash[:hierarchy] + stats_hash[:mapping]
    return stats_hash
  end

  def get_semantic_types()
    semantic_types = {}
    sty_prefix = 'http://bioportal.bioontology.org/ontologies/umls/sty/'
    begin
      sty_ont = LinkedData::Client::Models::Ontology.find_by_acronym('STY').first
      raise TypeError if sty_ont.nil?
      sty_classes = sty_ont.explore.classes({'pagesize'=>500})
      sty_classes.collection.each do |cls|
        code = cls.id.sub(sty_prefix,'')
        semantic_types[ code ] = cls.prefLabel
      end
      return semantic_types
    rescue Exception => e
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        LOG.add :debug, "\nERROR: failed to get semantic types."
        raise e
      end
    end
  end

end
