

# TODO: Put these requires and the get_json method into a new annotator client
require 'json'
require 'open-uri'
require 'cgi'


class AnnotatorController < ApplicationController
  layout 'ontology'

  #REST_URI = "http://stagedata.bioontology.org"
  REST_URI = "http://#{$REST_DOMAIN}"
  ANNOTATOR_URI = REST_URI + "/annotator"
  API_KEY = $API_KEY

  # TODO: Semantic types should be pulled from the new API (June, 2013)
  SEMANTIC_TYPES = [{:code=>"T000", :description=>"UMLS concept"}, {:code=>"T998", :description=>"Jax Mouse/Human Gene dictionary concept"}, {:code=>"T999", :description=>"NCBO BioPortal concept"}, {:code=>"T116", :description=>"Amino Acid, Peptide, or Protein"}, {:code=>"T121", :description=>"Pharmacologic Substance"}, {:code=>"T130", :description=>"Indicator, Reagent, or Diagnostic Aid"}, {:code=>"T119", :description=>"Lipid"}, {:code=>"T126", :description=>"Enzyme"}, {:code=>"T123", :description=>"Biologically Active Substance"}, {:code=>"T109", :description=>"Organic Chemical"}, {:code=>"T131", :description=>"Hazardous or Poisonous Substance"}, {:code=>"T110", :description=>"Steroid"}, {:code=>"T125", :description=>"Hormone"}, {:code=>"T114", :description=>"Nucleic Acid, Nucleoside, or Nucleotide"}, {:code=>"T111", :description=>"Eicosanoid"}, {:code=>"T118", :description=>"Carbohydrate"}, {:code=>"T124", :description=>"Neuroreactive Substance or Biogenic Amine"}, {:code=>"T127", :description=>"Vitamin"}, {:code=>"T195", :description=>"Antibiotic"}, {:code=>"T129", :description=>"Immunologic Factor"}, {:code=>"T024", :description=>"Tissue"}, {:code=>"T115", :description=>"Organophosphorus Compound"}, {:code=>"T073", :description=>"Manufactured Object"}, {:code=>"T081", :description=>"Quantitative Concept"}, {:code=>"T170", :description=>"Intellectual Product"}, {:code=>"T029", :description=>"Body Location or Region"}, {:code=>"T184", :description=>"Sign or Symptom"}, {:code=>"T033", :description=>"Finding"}, {:code=>"T037", :description=>"Injury or Poisoning"}, {:code=>"T191", :description=>"Neoplastic Process"}, {:code=>"T023", :description=>"Body Part, Organ, or Organ Component"}, {:code=>"T005", :description=>"Virus"}, {:code=>"T047", :description=>"Disease or Syndrome"}, {:code=>"T019", :description=>"Congenital Abnormality"}, {:code=>"T169", :description=>"Functional Concept"}, {:code=>"T190", :description=>"Anatomical Abnormality"}, {:code=>"T022", :description=>"Body System"}, {:code=>"T018", :description=>"Embryonic Structure"}, {:code=>"T101", :description=>"Patient or Disabled Group"}, {:code=>"T093", :description=>"Health Care Related Organization"}, {:code=>"T089", :description=>"Regulation or Law"}, {:code=>"T061", :description=>"Therapeutic or Preventive Procedure"}, {:code=>"T062", :description=>"Research Activity"}, {:code=>"T046", :description=>"Pathologic Function"}, {:code=>"T041", :description=>"Mental Process"}, {:code=>"T055", :description=>"Individual Behavior"}, {:code=>"T004", :description=>"Fungus"}, {:code=>"T060", :description=>"Diagnostic Procedure"}, {:code=>"T070", :description=>"Natural Phenomenon or Process"}, {:code=>"T197", :description=>"Inorganic Chemical"}, {:code=>"T057", :description=>"Occupational Activity"}, {:code=>"T083", :description=>"Geographic Area"}, {:code=>"T074", :description=>"Medical Device"}, {:code=>"T002", :description=>"Plant"}, {:code=>"T065", :description=>"Educational Activity"}, {:code=>"T092", :description=>"Organization"}, {:code=>"T009", :description=>"Invertebrate"}, {:code=>"T025", :description=>"Cell"}, {:code=>"T196", :description=>"Element, Ion, or Isotope"}, {:code=>"T067", :description=>"Phenomenon or Process"}, {:code=>"T080", :description=>"Qualitative Concept"}, {:code=>"T102", :description=>"Group Attribute"}, {:code=>"T098", :description=>"Population Group"}, {:code=>"T040", :description=>"Organism Function"}, {:code=>"T034", :description=>"Laboratory or Test Result"}, {:code=>"T201", :description=>"Clinical Attribute"}, {:code=>"T097", :description=>"Professional or Occupational Group"}, {:code=>"T064", :description=>"Governmental or Regulatory Activity"}, {:code=>"T054", :description=>"Social Behavior"}, {:code=>"T003", :description=>"Alga"}, {:code=>"T007", :description=>"Bacterium"}, {:code=>"T044", :description=>"Molecular Function"}, {:code=>"T053", :description=>"Behavior"}, {:code=>"T069", :description=>"Environmental Effect of Humans"}, {:code=>"T042", :description=>"Organ or Tissue Function"}, {:code=>"T103", :description=>"Chemical"}, {:code=>"T122", :description=>"Biomedical or Dental Material"}, {:code=>"T015", :description=>"Mammal"}, {:code=>"T020", :description=>"Acquired Abnormality"}, {:code=>"T030", :description=>"Body Space or Junction"}, {:code=>"T026", :description=>"Cell Component"}, {:code=>"T043", :description=>"Cell Function"}, {:code=>"T059", :description=>"Laboratory Procedure"}, {:code=>"T052", :description=>"Activity"}, {:code=>"T056", :description=>"Daily or Recreational Activity"}, {:code=>"T079", :description=>"Temporal Concept"}, {:code=>"T091", :description=>"Biomedical Occupation or Discipline"}, {:code=>"T192", :description=>"Receptor"}, {:code=>"T031", :description=>"Body Substance"}, {:code=>"T048", :description=>"Mental or Behavioral Dysfunction"}, {:code=>"T058", :description=>"Health Care Activity"}, {:code=>"T120", :description=>"Chemical Viewed Functionally"}, {:code=>"T100", :description=>"Age Group"}, {:code=>"T104", :description=>"Chemical Viewed Structurally"}, {:code=>"T171", :description=>"Language"}, {:code=>"T032", :description=>"Organism Attribute"}, {:code=>"T095", :description=>"Self-help or Relief Organization"}, {:code=>"T078", :description=>"Idea or Concept"}, {:code=>"T090", :description=>"Occupation or Discipline"}, {:code=>"T167", :description=>"Substance"}, {:code=>"T068", :description=>"Human-caused Phenomenon or Process"}, {:code=>"T168", :description=>"Food"}, {:code=>"T028", :description=>"Gene or Genome"}, {:code=>"T014", :description=>"Reptile"}, {:code=>"T050", :description=>"Experimental Model of Disease"}, {:code=>"T045", :description=>"Genetic Function"}, {:code=>"T011", :description=>"Amphibian"}, {:code=>"T013", :description=>"Fish"}, {:code=>"T094", :description=>"Professional Society"}, {:code=>"T087", :description=>"Amino Acid Sequence"}, {:code=>"T066", :description=>"Machine Activity"}, {:code=>"T185", :description=>"Classification"}, {:code=>"T006", :description=>"Rickettsia or Chlamydia"}, {:code=>"T049", :description=>"Cell or Molecular Dysfunction"}, {:code=>"T008", :description=>"Animal"}, {:code=>"T051", :description=>"Event"}, {:code=>"T038", :description=>"Biologic Function"}, {:code=>"T194", :description=>"Archaeon"}, {:code=>"T086", :description=>"Nucleotide Sequence"}, {:code=>"T039", :description=>"Physiologic Function"}, {:code=>"T012", :description=>"Bird"}, {:code=>"T063", :description=>"Molecular Biology Research Technique"}, {:code=>"T017", :description=>"Anatomical Structure"}, {:code=>"T082", :description=>"Spatial Concept"}, {:code=>"T088", :description=>"Carbohydrate Sequence"}, {:code=>"T099", :description=>"Family Group"}, {:code=>"T001", :description=>"Organism"}, {:code=>"T075", :description=>"Research Device"}, {:code=>"T096", :description=>"Group"}, {:code=>"T016", :description=>"Human"}, {:code=>"T072", :description=>"Physical Object"}, {:code=>"T071", :description=>"Entity"}, {:code=>"T200", :description=>"Clinical Drug"}, {:code=>"T085", :description=>"Molecular Sequence"}, {:code=>"T077", :description=>"Conceptual Entity"}, {:code=>"T010", :description=>"Vertebrate"}, {:code=>"T203", :description=>"Drug Delivery Device"}, {:code=>"T021", :description=>"Fully Formed Anatomical Structure"}, {:code=>"T204", :description=>"Eukaryote"}]

  # TODO: Evalute whether the ontologies hash could be in a REDIS key:value store.  If so, this could avoid all the repetitive API requests for basic ontology details.
  ONTOLOGIES = {}

  def index
    # DISABLE OLD API CLIENT
    #annotator = get_annotator_client
    #annotator.semantic_types.each do |st|
    #  @semantic_types_for_select << [ "#{st[:description]} (#{st[:semanticType]})", st[:semanticType]]
    #end
    #@semantic_types_for_select.sort! {|a,b| a[0] <=> b[0]}

    # TODO: Semantic types should be pulled from the new API (June, 2013)
    @semantic_types_for_select = []
    SEMANTIC_TYPES.each do |st|
      @semantic_types_for_select << [ "#{st[:description]} (#{st[:code]})", st[:code]]
    end
    @semantic_types_for_select.sort! {|a,b| a[0] <=> b[0]}


    # TODO: Duplicate the filteredOntologyList for the LinkedData client?
    #ontology_ids = []
    #annotator.ontologies.each {|ont| ontology_ids << ont[:virtualOntologyId]}
    #@annotator_ontologies = DataAccess.getFilteredOntologyList(ontology_ids)
    @annotator_ontologies = LinkedData::Client::Models::OntologySubmission.all
  end

  def create
    text_to_annotate = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    options = { :ontologies => params[:ontologies] ||= [],
                :max_level => params[:max_level].to_i ||= 0,
                :semanticTypes => params[:semanticTypes] ||= [],
                :mappingTypes => params[:mappingTypes] ||= [],
                # :wholeWordOnly => params[:wholeWordOnly] ||= true,  # service default is true
                # :withDefaultStopWords => params[:withDefaultStopWords] ||= true,  # service default is true
    }

    # TODO: Fix this
    # Add "My BioPortal" ontologies to the ontologies to keep in result parameter
    #OntologyFilter.pre(:annotator, options)

    # TODO: Fix this too.
    ## Make sure that custom ontologies exist in the annotator ontology set
    #if session[:user_ontologies]
    #  annotator_ontologies = Set.new([])
    #  annotator.ontologies.each {|ont| annotator_ontologies << ont[:virtualOntologyId]}
    #  options[:ontologiesToKeepInResult] = options[:ontologiesToKeepInResult].split(",") if options[:ontologiesToKeepInResult].kind_of?(String)
    #  options[:ontologiesToKeepInResult].reject! {|a| !annotator_ontologies.include?(a.to_i)}
    #end

    # DISABLE OLD API CLIENT
    #annotator = get_annotator_client
    #annotations = annotator.annotate(text, options)

    # TODO: Construct additional parameters in the query when they are supported.
    start = Time.now
    query = ANNOTATOR_URI
    query += "?text=" + CGI.escape(text_to_annotate)
    query += "&max_level=" + options[:max_level].to_s
    query += "&ontologies=" + CGI.escape(options[:ontologies].join(',')) unless options[:ontologies].empty?
    query += "&semanticTypes=" + options[:semanticTypes].join(',') unless options[:semanticTypes].empty?
    query += "&mappingTypes=" + options[:mappingTypes].join(',') unless options[:mappingTypes].empty?
    #query += "&wholeWordOnly=" + options[:wholeWordOnly].to_s unless options[:wholeWordOnly].empty?
    #query += "&withDefaultStopWords=" + options[:withDefaultStopWords].to_s unless options[:withDefaultStopWords].empty?
    annotations = parse_json(query) # parse_json adds APIKEY.
    LOG.add :debug, "Getting annotations: #{Time.now - start}s"

    # TODO: Evaluate whether the REST API could be doing this more efficiently.
    #classes = get_annotated_classes(annotations)


    start = Time.now
    annotations.each do |a|
      # Get the class details required for display, assume this is necessary
      # for every element of the annotations array because the API returns a set.
      # Replace the annotated class with these modified details.
      a["annotatedClass"] = get_class_details(a["annotatedClass"])
      a["hierarchy"].each do |h|
        h["annotatedClass"] = get_class_details(h["annotatedClass"])
      end
    end
    LOG.add :debug, "Modified annotations: #{Time.now - start}s"


    #
    # OLD API CODE...
    #
    #highlight_cache = {}
    #start = Time.now
    #context_ontologies = []
    #bad_annotations = []
    #annotations.annotations.each do |annotation|
    #  if highlight_cache.key?([annotation[:context][:from], annotation[:context][:to]])
    #    annotation[:context][:highlight] = highlight_cache[[annotation[:context][:from], annotation[:context][:to]]]
    #  else
    #    annotation[:context][:highlight] = highlight_and_get_context(text, [annotation[:context][:from], annotation[:context][:to]])
    #    highlight_cache[[annotation[:context][:from], annotation[:context][:to]]] = annotation[:context][:highlight]
    #  end
    #
    #  # Add ontology information, this isn't added for ontologies that are returned for mappings in cases where the ontology list is filtered
    #  context_concept = annotation[:context][:concept] ||= annotation[:context][:mappedConcept] ||= annotation[:concept]
    #  begin
    #
    #
    #    # TODO: Change out DataAccess for LinkedData client.
    #    context_ontologies << DataAccess.getOntology(context_concept[:localOntologyId])
    #
    #
    #
    #  rescue Error404
    #    # Get the appropriate ontology from the list of ontologies with annotations because the annotation itself doesn't contain the virtual id
    #    ont = annotations.ontologies.each {|ont| break ont if ont[:localOntologyId] == context_concept[:localOntologyId]}
    #    # Retry with the virtual id
    #    begin
    #
    #
    #      # TODO: Change out DataAccess for LinkedData client.
    #      context_ontologies << DataAccess.getOntology(ont[:virtualOntologyId])
    #
    #
    #    rescue Error404
    #      # If it failed with virtual id, mark the annotation as bad
    #      bad_annotations << annotation
    #    end
    #  end
    #end
    #
    ## Remove bad annotations
    #bad_annotations.each do |annotation|
    #  annotations.annotations.delete(annotation)
    #end
    #
    #annotations.statistics[:parameters] = { :textToAnnotate => text, :apikey => API_KEY }.merge(options)
    #LOG.add :debug, "Processing annotations: #{Time.now - start}s"
    #
    ## Combine all ontologies (context and normal) into a hash
    #ontologies_hash = {}
    #annotations.ontologies.each do |ont|
    #  ontologies_hash[ont[:localOntologyId]] = ont
    #end
    #
    #context_ontologies.each do |ont|
    #  next if ont.nil?
    #  if ontologies_hash[ont.id].nil?
    #    ontologies_hash[ont.id] = {
    #      :name => ont.displayLabel,
    #      :localOntologyId   => ont.id,
    #      :virtualOntologyId => ont.ontologyId
    #    }
    #  end
    #end
    #
    #annotations.ontologies = ontologies_hash

    render :json => annotations
  end

private

  def get_annotated_classes(annotations)
    # Use batch service to get prefLabels for all the annotated classes
  end

  def get_class_details(annotatedClass)
    # Get the class details required for display, assume this is necessary
    # for every element of the annotations array because the API returns a set?
    cls = {}
    cls["uri"] = annotatedClass["links"]["self"]  # TODO: Change to UI link.
    # Additional API request (synchronous)
    cls_details = parse_json(cls["uri"])   # parse_json adds APIKEY.
    cls["id"] = cls_details["@id"]
    cls["prefLabel"] = cls_details["prefLabel"]
    ont_uri = annotatedClass["links"]["ontology"]
    if ONTOLOGIES.keys.include? ont_uri
      # Use the saved ontology details to avoid repetitive API requests
      ont = ONTOLOGIES[ont_uri]
    else
      # Additional API request (synchronous)
      ont_details = parse_json(ont_uri)    # parse_json adds APIKEY.
      ont = {}
      ont["acronym"] = ont_details["acronym"]
      ont["name"] = ont_details["name"]
      ont["id"] = ont_details["@id"]
      ont["uri"] = ont_uri  # TODO: Change to UI link.
      ONTOLOGIES[ont_uri] = ont
    end
    cls["ontology"] = ont
    return cls
  end


  def highlight_and_get_context(text, position, words_to_keep = 4)
    # Process the highlighted text
    highlight = ["<span style='color: #006600; padding: 2px 0; font-weight: bold;'>", "", "</span>"]
    highlight[1] = text.utf8_slice(position[0] - 1, position[1] - position[0] + 1)

    # Use scan to split the text on spaces while keeping the spaces
    scan_filter = Regexp.new(/[ ]+?[-\?'"\+\.,]+\w+|[ ]+?[-\?'"\+\.,]+\w+[-\?'"\+\.,]|\w+[-\?'"\+\.,]+|[ ]+?\w+/)
    before = text.utf8_slice(0, position[0] - 1).match(/(\s+\S+|\S+\s+){0,4}$/).to_s
    after = text.utf8_slice(position[1], ActiveSupport::Multibyte::Chars.new(text).length - position[1]).match(/^(\S+\s+\S+|\s+\S+|\S+\s+){0,4}/).to_s

    # The process above will not keep a space right before the highlighted word, so let's keep it here if needed
    # 32 is the character code for space
    kept_space = text.utf8_slice(position[0] - 2) == " " ? " " : ""

    # Put it all together
    [before, kept_space, highlight.join, after].join
  end

  def get_apikey()
    apikey = API_KEY
    if session[:user]
      apikey = session[:user].apikey
    end
    return apikey
  end

  def parse_json(uri)
    JSON.parse(open(uri, "Authorization" => "apikey token=#{get_apikey}").read)
  end

  # DISABLE THE OLD API CLIENT
  #def get_annotator_client
  #  # https://github.com/ncbo/ncbo_annotator_ruby_client
  #  options = {:apikey => $API_KEY, :annotator_location => "http://#{$REST_DOMAIN}/obs"}
  #  if session[:user]
  #    options[:apikey] = session[:user].apikey
  #  end
  #  NCBO::Annotator.new(options)
  #end

end

