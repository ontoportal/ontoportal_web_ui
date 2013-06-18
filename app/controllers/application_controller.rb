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

  SEMANTIC_TYPES = [{:code=>"T000", :description=>"UMLS concept"}, {:code=>"T998", :description=>"Jax Mouse/Human Gene dictionary concept"}, {:code=>"T999", :description=>"NCBO BioPortal concept"}, {:code=>"T116", :description=>"Amino Acid, Peptide, or Protein"}, {:code=>"T121", :description=>"Pharmacologic Substance"}, {:code=>"T130", :description=>"Indicator, Reagent, or Diagnostic Aid"}, {:code=>"T119", :description=>"Lipid"}, {:code=>"T126", :description=>"Enzyme"}, {:code=>"T123", :description=>"Biologically Active Substance"}, {:code=>"T109", :description=>"Organic Chemical"}, {:code=>"T131", :description=>"Hazardous or Poisonous Substance"}, {:code=>"T110", :description=>"Steroid"}, {:code=>"T125", :description=>"Hormone"}, {:code=>"T114", :description=>"Nucleic Acid, Nucleoside, or Nucleotide"}, {:code=>"T111", :description=>"Eicosanoid"}, {:code=>"T118", :description=>"Carbohydrate"}, {:code=>"T124", :description=>"Neuroreactive Substance or Biogenic Amine"}, {:code=>"T127", :description=>"Vitamin"}, {:code=>"T195", :description=>"Antibiotic"}, {:code=>"T129", :description=>"Immunologic Factor"}, {:code=>"T024", :description=>"Tissue"}, {:code=>"T115", :description=>"Organophosphorus Compound"}, {:code=>"T073", :description=>"Manufactured Object"}, {:code=>"T081", :description=>"Quantitative Concept"}, {:code=>"T170", :description=>"Intellectual Product"}, {:code=>"T029", :description=>"Body Location or Region"}, {:code=>"T184", :description=>"Sign or Symptom"}, {:code=>"T033", :description=>"Finding"}, {:code=>"T037", :description=>"Injury or Poisoning"}, {:code=>"T191", :description=>"Neoplastic Process"}, {:code=>"T023", :description=>"Body Part, Organ, or Organ Component"}, {:code=>"T005", :description=>"Virus"}, {:code=>"T047", :description=>"Disease or Syndrome"}, {:code=>"T019", :description=>"Congenital Abnormality"}, {:code=>"T169", :description=>"Functional Concept"}, {:code=>"T190", :description=>"Anatomical Abnormality"}, {:code=>"T022", :description=>"Body System"}, {:code=>"T018", :description=>"Embryonic Structure"}, {:code=>"T101", :description=>"Patient or Disabled Group"}, {:code=>"T093", :description=>"Health Care Related Organization"}, {:code=>"T089", :description=>"Regulation or Law"}, {:code=>"T061", :description=>"Therapeutic or Preventive Procedure"}, {:code=>"T062", :description=>"Research Activity"}, {:code=>"T046", :description=>"Pathologic Function"}, {:code=>"T041", :description=>"Mental Process"}, {:code=>"T055", :description=>"Individual Behavior"}, {:code=>"T004", :description=>"Fungus"}, {:code=>"T060", :description=>"Diagnostic Procedure"}, {:code=>"T070", :description=>"Natural Phenomenon or Process"}, {:code=>"T197", :description=>"Inorganic Chemical"}, {:code=>"T057", :description=>"Occupational Activity"}, {:code=>"T083", :description=>"Geographic Area"}, {:code=>"T074", :description=>"Medical Device"}, {:code=>"T002", :description=>"Plant"}, {:code=>"T065", :description=>"Educational Activity"}, {:code=>"T092", :description=>"Organization"}, {:code=>"T009", :description=>"Invertebrate"}, {:code=>"T025", :description=>"Cell"}, {:code=>"T196", :description=>"Element, Ion, or Isotope"}, {:code=>"T067", :description=>"Phenomenon or Process"}, {:code=>"T080", :description=>"Qualitative Concept"}, {:code=>"T102", :description=>"Group Attribute"}, {:code=>"T098", :description=>"Population Group"}, {:code=>"T040", :description=>"Organism Function"}, {:code=>"T034", :description=>"Laboratory or Test Result"}, {:code=>"T201", :description=>"Clinical Attribute"}, {:code=>"T097", :description=>"Professional or Occupational Group"}, {:code=>"T064", :description=>"Governmental or Regulatory Activity"}, {:code=>"T054", :description=>"Social Behavior"}, {:code=>"T003", :description=>"Alga"}, {:code=>"T007", :description=>"Bacterium"}, {:code=>"T044", :description=>"Molecular Function"}, {:code=>"T053", :description=>"Behavior"}, {:code=>"T069", :description=>"Environmental Effect of Humans"}, {:code=>"T042", :description=>"Organ or Tissue Function"}, {:code=>"T103", :description=>"Chemical"}, {:code=>"T122", :description=>"Biomedical or Dental Material"}, {:code=>"T015", :description=>"Mammal"}, {:code=>"T020", :description=>"Acquired Abnormality"}, {:code=>"T030", :description=>"Body Space or Junction"}, {:code=>"T026", :description=>"Cell Component"}, {:code=>"T043", :description=>"Cell Function"}, {:code=>"T059", :description=>"Laboratory Procedure"}, {:code=>"T052", :description=>"Activity"}, {:code=>"T056", :description=>"Daily or Recreational Activity"}, {:code=>"T079", :description=>"Temporal Concept"}, {:code=>"T091", :description=>"Biomedical Occupation or Discipline"}, {:code=>"T192", :description=>"Receptor"}, {:code=>"T031", :description=>"Body Substance"}, {:code=>"T048", :description=>"Mental or Behavioral Dysfunction"}, {:code=>"T058", :description=>"Health Care Activity"}, {:code=>"T120", :description=>"Chemical Viewed Functionally"}, {:code=>"T100", :description=>"Age Group"}, {:code=>"T104", :description=>"Chemical Viewed Structurally"}, {:code=>"T171", :description=>"Language"}, {:code=>"T032", :description=>"Organism Attribute"}, {:code=>"T095", :description=>"Self-help or Relief Organization"}, {:code=>"T078", :description=>"Idea or Concept"}, {:code=>"T090", :description=>"Occupation or Discipline"}, {:code=>"T167", :description=>"Substance"}, {:code=>"T068", :description=>"Human-caused Phenomenon or Process"}, {:code=>"T168", :description=>"Food"}, {:code=>"T028", :description=>"Gene or Genome"}, {:code=>"T014", :description=>"Reptile"}, {:code=>"T050", :description=>"Experimental Model of Disease"}, {:code=>"T045", :description=>"Genetic Function"}, {:code=>"T011", :description=>"Amphibian"}, {:code=>"T013", :description=>"Fish"}, {:code=>"T094", :description=>"Professional Society"}, {:code=>"T087", :description=>"Amino Acid Sequence"}, {:code=>"T066", :description=>"Machine Activity"}, {:code=>"T185", :description=>"Classification"}, {:code=>"T006", :description=>"Rickettsia or Chlamydia"}, {:code=>"T049", :description=>"Cell or Molecular Dysfunction"}, {:code=>"T008", :description=>"Animal"}, {:code=>"T051", :description=>"Event"}, {:code=>"T038", :description=>"Biologic Function"}, {:code=>"T194", :description=>"Archaeon"}, {:code=>"T086", :description=>"Nucleotide Sequence"}, {:code=>"T039", :description=>"Physiologic Function"}, {:code=>"T012", :description=>"Bird"}, {:code=>"T063", :description=>"Molecular Biology Research Technique"}, {:code=>"T017", :description=>"Anatomical Structure"}, {:code=>"T082", :description=>"Spatial Concept"}, {:code=>"T088", :description=>"Carbohydrate Sequence"}, {:code=>"T099", :description=>"Family Group"}, {:code=>"T001", :description=>"Organism"}, {:code=>"T075", :description=>"Research Device"}, {:code=>"T096", :description=>"Group"}, {:code=>"T016", :description=>"Human"}, {:code=>"T072", :description=>"Physical Object"}, {:code=>"T071", :description=>"Entity"}, {:code=>"T200", :description=>"Clinical Drug"}, {:code=>"T085", :description=>"Molecular Sequence"}, {:code=>"T077", :description=>"Conceptual Entity"}, {:code=>"T010", :description=>"Vertebrate"}, {:code=>"T203", :description=>"Drug Delivery Device"}, {:code=>"T021", :description=>"Fully Formed Anatomical Structure"}, {:code=>"T204", :description=>"Eukaryote"}]
  SEMANTIC_DICT = {}
  SEMANTIC_TYPES.each do |st|
    SEMANTIC_DICT[st[:code]] = st[:description]
  end

  # TODO: Semantic types should be pulled from the new API (June, 2013)
  #SEMANTIC_DICT = get_semantic_types
  #def get_semantic_types
  #  semantic_types = {}
  #  sty_uri = 'http://stagedata.bioontology.org/ontologies/STY'
  #  sty_ont = LinkedData::Client::Models::Ontology.find(sty_uri)
  #  sty_classes = sty_ont.explore.classes
  #  # TODO: work with pagination??
  #  #while sty_classes.links.nextPage
  #    sty_classes.collection.each do |cls|
  #      code = cls['prefLabel']
  #      semantic_types[ code ] = cls['description']
  #    end
  #    # Request the next page?
  #  #end
  #  return semantic_types
  #end



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


  def get_ontology_details(ont_uri)
    begin
      ont_model = LinkedData::Client::Models::Ontology.find(ont_uri)
      ont = {}
      ont['uri'] = ont_uri
      ont['ui'] =  ont_model.links['ui']
      ont['acronym'] = ont_model.acronym
      ont['name'] = ont_model.name
      ont['id'] = ont_model.id
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
