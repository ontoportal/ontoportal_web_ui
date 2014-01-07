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
  REST_URI = $REST_URL
  API_KEY = $API_KEY

  REST_URI_BATCH = REST_URI + '/batch'
  REST_URI_RECENT_MAPPINGS = "#{REST_URI}/mappings/recent/"

  # Constants used primarily in the resource_index_controller, but also elsewhere.
  RESOURCE_INDEX_URI = REST_URI + '/resource_index'
  RI_ELEMENT_ANNOTATIONS_URI = RESOURCE_INDEX_URI + '/element_annotations'
  RI_ONTOLOGIES_URI = RESOURCE_INDEX_URI + '/ontologies'
  RI_RANKED_ELEMENTS_URI = RESOURCE_INDEX_URI + '/ranked_elements'
  RI_RESOURCES_URI = RESOURCE_INDEX_URI + '/resources'
  # Note that STATS is a DIRECT CONNECTION to the JAVA-REST API
  RI_STATS_URI = 'http://rest.bioontology.org/resource_index/statistics/all'

  # Rails.cache expiration
  EXPIRY_RI_STATS = 60 * 60 * 24       # 24:00 hours
  EXPIRY_RI_ONTOLOGIES = 60 * 60 * 24  # 24:00 hours
  EXPIRY_SEMANTIC_TYPES = 60 * 60 * 24 # 24:00 hours
  EXPIRY_RECENT_MAPPINGS = 60 * 60     #  1:00 hours
  EXPIRY_ONTOLOGY_SIMPLIFIED = 60 * 1  #  0:01 minute


  if !$EMAIL_EXCEPTIONS.nil? && $EMAIL_EXCEPTIONS == true
    include ExceptionNotifiable
  end

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  before_filter :set_global_thread_values, :domain_ontology_set, :authorize_miniprofiler

  def set_global_thread_values
    Thread.current[:session] = session
    Thread.current[:request] = request
  end

  def domain_ontology_set
    @subdomain_filter = { :active => false, :name => "", :acronym => "" }

    if !$ENABLE_SLICES.nil? && $ENABLE_SLICES == true
      host = request.host
      host_parts = host.split(".")
      subdomain = host_parts[0].downcase

      slices = LinkedData::Client::Models::Slice.all
      slices_acronyms = slices.map {|s| s.acronym}

      # Set custom ontologies if we're on a subdomain that has them
      # Else, make sure user ontologies are set appropriately
      if slices_acronyms.include?(subdomain)
        slice = slices.select {|s| s.acronym.eql?(subdomain)}.first
        @subdomain_filter[:active] = true
        @subdomain_filter[:name] = slice.name
        @subdomain_filter[:acronym] = slice.acronym
      end
    end

    Thread.current[:slice] = @subdomain_filter
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
    if params[:conceptid] && !params[:conceptid].start_with?("http")
      uri = BPIDResolver.uri_from_short_id(acronym, params[:conceptid])
      params[:conceptid] = uri if uri
    end
    if class_view
      redirect_to "/ontologies/#{acronym}?p=classes#{params_string_for_redirect(params, prefix: "&")}", :status => :moved_permanently
    else
      redirect_to "/ontologies/#{acronym}#{params_string_for_redirect(params)}", :status => :moved_permanently
    end
  end

  def params_cleanup_new_api
    params = @_params
    if params[:ontology] && params[:ontology].to_i > 0
      params[:ontology] = BPIDResolver.id_to_acronym(params[:ontology])
    end

    if params[:ontology] && params[:conceptid] && !params[:conceptid].start_with?("http")
      uri = BPIDResolver.uri_from_short_id(params[:ontology], params[:conceptid])
      params[:conceptid] = uri if uri
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
  def authorize_miniprofiler
    if session[:user] && session[:user].admin?
      Rack::MiniProfiler.authorize_request
    elsif params[:enable_profiler] && params[:enable_profiler].eql?("true")
      Rack::MiniProfiler.authorize_request
    else
      Rack::MiniProfiler.deauthorize_request
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
    # ensure mappings is an Array of mappings (some calls may provide only a single mapping instance)
    mappings = [mappings] if mappings.instance_of? LinkedData::Client::Models::Mapping
    delete_mapping_permission = false
    if session[:user]
      delete_mapping_permission = session[:user].admin?
      mappings.each do |mapping|
        break if delete_mapping_permission
        delete_mapping_permission = mapping.creator == session[:user].id
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
      # TODO_REV: Support views? Replace old view call: @ontology.top_level_classes(view)
      root_children = @ontology.explore.roots
      root_children.sort!{|x,y| (x.prefLabel || "").downcase <=> (y.prefLabel || "").downcase}

      @root.children = root_children

      # get the initial concept to display
      @concept = @root.children.first.explore.self(full: true)

      # Some ontologies have "too many children" at their root. These will not process and are handled here.
      raise Error404 if @concept.nil?
    elsif @ontology.flat? && (!params[:conceptid] || params[:conceptid].empty? || params[:conceptid].eql?("root") || params[:conceptid].eql?("bp_fake_root"))
      # Don't display any classes in the tree
      @concept = LinkedData::Client::Models::Class.new
      @concept.prefLabel = "Please search for a class using the Jump To field above"
      @concept.id = "bp_fake_root"
      @concept.child_size = 0
      @concept.properties = {}
      @concept.children = []
      @root = LinkedData::Client::Models::Class.new
      @root.children = [@concept]
    elsif @ontology.flat? && params[:conceptid]
      # Display only the requested class in the tree
      @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
      @concept.children = []
      @concept.child_size = 0
      @root = LinkedData::Client::Models::Class.new
      @root.children = [@concept]
    else
      # if the id is coming from a param, use that to get concept
      @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
      raise Error404 if @concept.nil? || @concept.errors

      # Create the tree
      rootNode = @concept.explore.tree(include: "prefLabel,childrenCount")

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

  def get_ontology_submission_ready(ontology)
    # Get the latest 'ready' submission
    submission = ontology.explore.latest_submission({:include_status => 'ready'})
    # Fallback to the latest submission, even if it's not ready.
    submission = ontology.explore.latest_submission if submission.nil?
    return submission
  end

  def get_simplified_ontologies_hash()
    # Note the simplify_ontology_model will cache individual ontology data.
    simple_ontologies = {}
    begin
      ontology_models = LinkedData::Client::Models::Ontology.all({:include_views => true})
      ontology_models.each {|o| simple_ontologies[o.id] = simplify_ontology_model(o) }
    rescue Exception => e
      LOG.add :error, e.message
      return nil
    end
    return simple_ontologies
  end

  def get_ontology_details(ont_uri)
    # Note the simplify_ontology_model will cache individual ontology data.
    begin
      ont_model = LinkedData::Client::Models::Ontology.find(ont_uri)
      ont = simplify_ontology_model(ont_model)
    rescue Exception => e
      LOG.add :error, e.message
      return nil
    end
    return ont
  end

  def simplify_classes(classes)
    # Simplify the classes batch service data for the UI
    # It takes a list of class objects (hashes or models) and the
    # data structure returned is a hash of class hashes, which will
    # contain details for the ontology they belong to.  For example:
    #{
    # "http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#C12439" => {
    #    :id => "http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#C12439",
    #    :ui => "http://ncbo-stg-app-12.stanford.edu/ontologies/NCIT?p=classes&conceptid=http%3A%2F%2Fncicb.nci.nih.gov%2Fxml%2Fowl%2FEVS%2FThesaurus.owl%23C12439",
    #    :uri => "http://stagedata.bioontology.org/ontologies/NCIT/classes/http%3A%2F%2Fncicb.nci.nih.gov%2Fxml%2Fowl%2FEVS%2FThesaurus.owl%23C12439",
    #    :prefLabel => "Brain",
    #    :ontology => {
    #      :id => "http://stagedata.bioontology.org/ontologies/NCIT",
    #      :uri => "http://stagedata.bioontology.org/ontologies/NCIT",
    #      :acronym => "NCIT",
    #      :name => "National Cancer Institute Thesaurus",
    #      :ui => "http://ncbo-stg-app-12.stanford.edu/ontologies/NCIT"
    #    },
    #  },
    #}
    @ontologies_hash ||= get_simplified_ontologies_hash
    classes_hash = {}
    classes.each do |cls|
      c = simplify_class_model(cls)
      c[:ontology] = @ontologies_hash[ c[:ontology] ]
      classes_hash[c[:id]] = c
    end
    return classes_hash
  end

  def simplify_class_model(cls_model)
    # Simplify the class required required by the UI.
    # No modification of the class ontology here, see simplify_classes.
    # Default simple class model
    cls = { :id => nil, :ontology => nil, :prefLabel => nil, :uri => nil, :ui => nil, :obsolete => false }
    begin
      if cls_model.instance_of? Hash
        cls = {
            :id => cls_model['@id'],
            :ui =>  cls_model['links']['ui'],
            :uri => cls_model['links']['self'],  # different from id
            :ontology => cls_model['links']['ontology']
        }
        # Try to carry through a prefLabel and the obsolete attribute, if they exist.
        cls[:prefLabel] = cls_model['prefLabel']
        cls[:obsolete] = cls_model['obsolete'] || false
      else
        # try to work with a struct object or a LinkedData::Client::Models::Class
        # if not a struct, then: cls_model.instance_of? LinkedData::Client::Models::Class
        cls = {
            :id => cls_model.id,
            :ui =>  cls_model.links['ui'],
            :uri => cls_model.links['self'],  # different from id
            :ontology => cls_model.links['ontology'],
        }
        # Try to carry through a prefLabel and the obsolete attribute, if they exist.
        cls[:prefLabel] = cls_model.prefLabel if cls_model.respond_to?('prefLabel')
        cls[:obsolete] = cls_model.respond_to?('obsolete') && cls_model.obsolete || false
      end
    rescue Exception => e
      LOG.add :error, e.message
      LOG.add :error, "Failure to simplify class: #{cls}"
    end
    return cls
  end

  def simplify_ontology_model(ont_model)
    id = nil
    if ont_model.instance_of? Hash
      id = ont_model['@id']
    elsif ont_model.instance_of? LinkedData::Client::Models::Ontology
      id = ont_model.id
    end
    ont = Rails.cache.read(id)
    return ont unless ont.nil?
    # No cache or it has expired
    LOG.add :debug, "No cache or expired cache for ontology: #{id}"
    ont = {}
    ont[:id] = id
    ont[:uri] = id
    if ont_model.instance_of? Hash
      ont[:acronym] = ont_model['acronym']
      ont[:name] = ont_model['name']
      ont[:ui] = ont_model['links']['ui']
    else
      # try to work with a struct object or a LinkedData::Client::Models::Ontology
      # if not a struct, then: ont_model.instance_of? LinkedData::Client::Models::Ontology
      ont[:acronym] = ont_model.acronym
      ont[:name] = ont_model.name
      ont[:ui] = ont_model.links['ui']
    end
    # Only cache a complete representation of a simplified ontology
    if ont[:id].nil? || ont[:uri].nil? || ont[:acronym].nil? || ont[:name].nil? || ont[:ui].nil?
      raise "Incomplete simple ontology: #{id}, #{ont}"
    else
      Rails.cache.write(ont[:id], ont, expires_in: EXPIRY_ONTOLOGY_SIMPLIFIED)
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
    begin
      response = RestClient.post REST_URI_BATCH, params.to_json, :content_type => :json, :accept => :json, :authorization => "apikey token=#{get_apikey}"
    rescue Exception => error
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        LOG.add :debug, "\nERROR: batch POST, uri: #{REST_URI_BATCH}"
        LOG.add :debug, "\nERROR: batch POST, params: #{params.to_json}"
        LOG.add :debug, "\nERROR: batch POST, error response: #{error.response}"
        raise error
      end
    end
    response
  end

  def get_recent_mappings
    recent_mappings = {
        :mappings => [],
        :classes => {}
    }
    begin
      cached_mappings_key = REST_URI_RECENT_MAPPINGS
      cached_mappings = Rails.cache.read(cached_mappings_key)
      return cached_mappings unless (cached_mappings.nil? || cached_mappings.empty?)
      # No cache or it has expired
      class_details = {}
      mappings = LinkedData::Client::HTTP.get(REST_URI_RECENT_MAPPINGS)
      unless mappings.nil? || mappings.empty?
        # There is no 'include' parameter on the /mappings/recent API.
        # The following is required just to get the prefLabel on each mapping class.
        class_list = mappings.map {|m| m.classes.map {|c| { :class => c.id, :ontology => c.links['ontology'] } } }.flatten
        # make the batch call to get all the class prefLabel values
        call_params = {'http://www.w3.org/2002/07/owl#Class'=>{'collection'=>class_list, 'include'=>'prefLabel'}}
        class_response = get_batch_results(call_params)  # method in application_controller.rb
        # Simplify the response data for the UI
        class_results = JSON.parse(class_response)
        class_details = simplify_classes(class_results["http://www.w3.org/2002/07/owl#Class"])
      else
        LOG.add :error, "No recent mappings: #{mappings}"
      end
      recent_mappings[:mappings] = mappings
      recent_mappings[:classes] = class_details
      unless mappings.nil? || class_details.nil?
        unless mappings.empty? || class_details.empty?
          # Only cache a successful retrieval
          Rails.cache.write(cached_mappings_key, recent_mappings, expires_in: EXPIRY_RECENT_MAPPINGS)
        end
      end
    rescue Exception => e
      LOG.add :error, e.message
      # leave recent mappings empty.
    end
    return recent_mappings
  end

  def get_resource_index_resources
    return LinkedData::Client::HTTP.get(RI_RESOURCES_URI)
  end

  def get_resource_index_ontologies
    return LinkedData::Client::HTTP.get(RI_ONTOLOGIES_URI)
  end

  def get_resource_index_annotation_stats
    begin
      stats_hash = Rails.cache.read(RI_STATS_URI)
      return stats_hash unless stats_hash.nil?
      uri = RI_STATS_URI + '?apikey=' + get_apikey
      ri_statsConn = open(uri)
      doc = REXML::Document.new(ri_statsConn)
      stats = doc.elements["/success/data/statistics"]
      stats_hash = {}
      stats_hash[:total] = stats.elements["aggregatedAnnotations"].get_text.value.strip.to_i
      stats_hash[:direct] = stats.elements["mgrepAnnotations"].get_text.value.strip.to_i
      stats_hash[:reported] = stats.elements["reportedAnnotations"].get_text.value.strip.to_i
      stats_hash[:hierarchy] = stats.elements["isaAnnotations"].get_text.value.strip.to_i
      stats_hash[:mapping] = stats.elements["mappingAnnotations"].get_text.value.strip.to_i
      stats_hash[:expanded] = stats_hash[:direct] + stats_hash[:hierarchy] + stats_hash[:mapping]
      Rails.cache.write(RI_STATS_URI, stats_hash, expires_in: EXPIRY_RI_STATS)
    rescue Exception => e
      LOG.add :error, e.message
      stats_hash = {
          :total => 'n/a',
          :direct => 'n/a',
          :reported => 'n/a',
          :hierarchy => 'n/a',
          :mapping => 'n/a',
          :expanded => 'n/a'
      }
    end
    return stats_hash
  end

  def get_semantic_types
    semantic_types_key = 'semantic_types_key'
    semantic_types = Rails.cache.read(semantic_types_key)
    return semantic_types if not semantic_types.nil?
    semantic_types = {}
    sty_prefix = 'http://bioportal.bioontology.org/ontologies/umls/sty/'
    begin
      sty_ont = LinkedData::Client::Models::Ontology.find_by_acronym('STY').first
      raise TypeError if sty_ont.nil?
      # The first 500 items should be more than sufficient to get all semantic types.
      sty_classes = sty_ont.explore.classes({'pagesize'=>500, include: 'prefLabel'})
      sty_classes.collection.each do |cls|
        code = cls.id.sub(sty_prefix,'')
        semantic_types[ code ] = cls.prefLabel
      end
      # Only cache a successful retrieval
      Rails.cache.write(semantic_types_key, semantic_types, expires_in: EXPIRY_SEMANTIC_TYPES)
    rescue Exception => e
      @retries ||= 0
      if @retries < 1  # retry once only
        @retries += 1
        retry
      else
        LOG.add :error, "Failed to get semantic types: #{e.message}"
        # raise e  # let it fail and return an empty set of semantic types
      end
    end
    return semantic_types
  end

  def massage_annotated_classes(annotations, options)
    # Get the class details required for display, assume this is necessary
    # for every element of the annotations array because the API returns a set.
    # Use the batch REST API to get all the annotated class prefLabels.
    start = Time.now
    semantic_types = options[:semantic_types] || []
    class_details = get_annotated_classes(annotations, semantic_types)
    simplify_annotated_classes(annotations, class_details)
    # repeat the simplification for any annotation hierarchy or mappings.
    hierarchy = annotations.map {|a| a if a.keys.include? 'hierarchy' }.compact
    hierarchy.each do |a|
      simplify_annotated_classes(a['hierarchy'], class_details) if not a['hierarchy'].empty?
    end
    mappings = annotations.map {|a| a if a.keys.include? 'mappings' }.compact
    mappings.each do |a|
      simplify_annotated_classes(a['mappings'], class_details) if not a['mappings'].empty?
    end
    LOG.add :debug, "Completed massage for annotated classes: #{Time.now - start}s"
  end

  def simplify_annotated_classes(annotations, class_details)
    annotations2delete = []
    annotations.each do |a|
      cls_id = a['annotatedClass']['@id']
      details = class_details[cls_id]
      if details.nil?
        LOG.add :debug, "Failed to get class details for: #{a['annotatedClass']['links']['self']}"
        annotations2delete.push(cls_id)
      else
        # Replace the annotated class with simplified details.
        a['annotatedClass'] = details
      end
    end
    # Remove any annotations that fail to resolve details.
    annotations.delete_if { |a| annotations2delete.include? a['annotatedClass']['@id'] }
  end

  def get_annotated_class_hash(a)
    return {
        :class => a['annotatedClass']['@id'],
        :ontology => a['annotatedClass']['links']['ontology']
    }
  end

  def get_annotated_classes(annotations, semantic_types=[])
    # Use batch service to get class prefLabels
    class_list = []
    annotations.each {|a| class_list << get_annotated_class_hash(a) }
    hierarchy = annotations.map {|a| a if a.keys.include? 'hierarchy' }.compact
    hierarchy.each do |a|
      a['hierarchy'].each {|h| class_list << get_annotated_class_hash(h) }
    end
    mappings = annotations.map {|a| a if a.keys.include? 'mappings' }.compact
    mappings.each do |a|
      a['mappings'].each {|m| class_list << get_annotated_class_hash(m) }
    end
    classes_simple = {}
    return classes_simple if class_list.empty?
    # remove duplicates
    class_set = class_list.to_set # get unique class:ontology set
    class_list = class_set.to_a   # collection requires a list in batch call
    # make the batch call
    properties = 'prefLabel'
    properties = 'prefLabel,semanticType' if not semantic_types.empty?
    call_params = {'http://www.w3.org/2002/07/owl#Class'=>{'collection'=>class_list, 'include'=>properties}}
    classes_json = get_batch_results(call_params)
    # Simplify the response data for the UI
    @ontologies_hash ||= get_simplified_ontologies_hash # application_controller
    classes_data = JSON.parse(classes_json)
    classes_data["http://www.w3.org/2002/07/owl#Class"].each do |cls|
      c = simplify_class_model(cls)
      ont_details = @ontologies_hash[ c[:ontology] ]
      next if ont_details.nil? # NO DISPLAY FOR ANNOTATIONS ON ANY CLASS OUTSIDE THE BIOPORTAL ONTOLOGY SET.
      c[:ontology] = ont_details
      unless semantic_types.empty? || cls['semanticType'].nil?
        @semantic_types ||= get_semantic_types   # application_controller
        # Extract the semantic type descriptions that are requested.
        semanticTypeURI = 'http://bioportal.bioontology.org/ontologies/umls/sty/'
        semanticCodes = cls['semanticType'].map {|t| t.sub( semanticTypeURI, '') }
        requestedCodes = semanticCodes.map {|code| (semantic_types.include? code and code) || nil }.compact
        requestedDescriptions = requestedCodes.map {|code| @semantic_types[code] }.compact
        c[:semantic_types] = requestedDescriptions
      else
        c[:semantic_types] = []
      end
      classes_simple[c[:id]] = c
    end
    return classes_simple
  end

end
