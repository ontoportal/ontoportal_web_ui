
# TODO: Put these requires and the get_json method into a new annotator client
require 'json'
require 'open-uri'
require 'cgi'
require 'rest-client'
require 'ontologies_api_client'

class AnnotatorController < ApplicationController
  layout 'ontology'

  REST_URI = "http://#{$REST_DOMAIN}"
  ANNOTATOR_URI = REST_URI + "/annotator"
  API_KEY = $API_KEY

  # TODO: Evalute whether the ontologies hash could be in a REDIS key:value store.  If so, this could avoid all the repetitive API requests for basic ontology details.
  ONTOLOGIES = {}

  # TODO: Semantic types should be pulled from the new API (June, 2013)
  SEMANTIC_TYPES = [{:code=>"T000", :description=>"UMLS concept"}, {:code=>"T998", :description=>"Jax Mouse/Human Gene dictionary concept"}, {:code=>"T999", :description=>"NCBO BioPortal concept"}, {:code=>"T116", :description=>"Amino Acid, Peptide, or Protein"}, {:code=>"T121", :description=>"Pharmacologic Substance"}, {:code=>"T130", :description=>"Indicator, Reagent, or Diagnostic Aid"}, {:code=>"T119", :description=>"Lipid"}, {:code=>"T126", :description=>"Enzyme"}, {:code=>"T123", :description=>"Biologically Active Substance"}, {:code=>"T109", :description=>"Organic Chemical"}, {:code=>"T131", :description=>"Hazardous or Poisonous Substance"}, {:code=>"T110", :description=>"Steroid"}, {:code=>"T125", :description=>"Hormone"}, {:code=>"T114", :description=>"Nucleic Acid, Nucleoside, or Nucleotide"}, {:code=>"T111", :description=>"Eicosanoid"}, {:code=>"T118", :description=>"Carbohydrate"}, {:code=>"T124", :description=>"Neuroreactive Substance or Biogenic Amine"}, {:code=>"T127", :description=>"Vitamin"}, {:code=>"T195", :description=>"Antibiotic"}, {:code=>"T129", :description=>"Immunologic Factor"}, {:code=>"T024", :description=>"Tissue"}, {:code=>"T115", :description=>"Organophosphorus Compound"}, {:code=>"T073", :description=>"Manufactured Object"}, {:code=>"T081", :description=>"Quantitative Concept"}, {:code=>"T170", :description=>"Intellectual Product"}, {:code=>"T029", :description=>"Body Location or Region"}, {:code=>"T184", :description=>"Sign or Symptom"}, {:code=>"T033", :description=>"Finding"}, {:code=>"T037", :description=>"Injury or Poisoning"}, {:code=>"T191", :description=>"Neoplastic Process"}, {:code=>"T023", :description=>"Body Part, Organ, or Organ Component"}, {:code=>"T005", :description=>"Virus"}, {:code=>"T047", :description=>"Disease or Syndrome"}, {:code=>"T019", :description=>"Congenital Abnormality"}, {:code=>"T169", :description=>"Functional Concept"}, {:code=>"T190", :description=>"Anatomical Abnormality"}, {:code=>"T022", :description=>"Body System"}, {:code=>"T018", :description=>"Embryonic Structure"}, {:code=>"T101", :description=>"Patient or Disabled Group"}, {:code=>"T093", :description=>"Health Care Related Organization"}, {:code=>"T089", :description=>"Regulation or Law"}, {:code=>"T061", :description=>"Therapeutic or Preventive Procedure"}, {:code=>"T062", :description=>"Research Activity"}, {:code=>"T046", :description=>"Pathologic Function"}, {:code=>"T041", :description=>"Mental Process"}, {:code=>"T055", :description=>"Individual Behavior"}, {:code=>"T004", :description=>"Fungus"}, {:code=>"T060", :description=>"Diagnostic Procedure"}, {:code=>"T070", :description=>"Natural Phenomenon or Process"}, {:code=>"T197", :description=>"Inorganic Chemical"}, {:code=>"T057", :description=>"Occupational Activity"}, {:code=>"T083", :description=>"Geographic Area"}, {:code=>"T074", :description=>"Medical Device"}, {:code=>"T002", :description=>"Plant"}, {:code=>"T065", :description=>"Educational Activity"}, {:code=>"T092", :description=>"Organization"}, {:code=>"T009", :description=>"Invertebrate"}, {:code=>"T025", :description=>"Cell"}, {:code=>"T196", :description=>"Element, Ion, or Isotope"}, {:code=>"T067", :description=>"Phenomenon or Process"}, {:code=>"T080", :description=>"Qualitative Concept"}, {:code=>"T102", :description=>"Group Attribute"}, {:code=>"T098", :description=>"Population Group"}, {:code=>"T040", :description=>"Organism Function"}, {:code=>"T034", :description=>"Laboratory or Test Result"}, {:code=>"T201", :description=>"Clinical Attribute"}, {:code=>"T097", :description=>"Professional or Occupational Group"}, {:code=>"T064", :description=>"Governmental or Regulatory Activity"}, {:code=>"T054", :description=>"Social Behavior"}, {:code=>"T003", :description=>"Alga"}, {:code=>"T007", :description=>"Bacterium"}, {:code=>"T044", :description=>"Molecular Function"}, {:code=>"T053", :description=>"Behavior"}, {:code=>"T069", :description=>"Environmental Effect of Humans"}, {:code=>"T042", :description=>"Organ or Tissue Function"}, {:code=>"T103", :description=>"Chemical"}, {:code=>"T122", :description=>"Biomedical or Dental Material"}, {:code=>"T015", :description=>"Mammal"}, {:code=>"T020", :description=>"Acquired Abnormality"}, {:code=>"T030", :description=>"Body Space or Junction"}, {:code=>"T026", :description=>"Cell Component"}, {:code=>"T043", :description=>"Cell Function"}, {:code=>"T059", :description=>"Laboratory Procedure"}, {:code=>"T052", :description=>"Activity"}, {:code=>"T056", :description=>"Daily or Recreational Activity"}, {:code=>"T079", :description=>"Temporal Concept"}, {:code=>"T091", :description=>"Biomedical Occupation or Discipline"}, {:code=>"T192", :description=>"Receptor"}, {:code=>"T031", :description=>"Body Substance"}, {:code=>"T048", :description=>"Mental or Behavioral Dysfunction"}, {:code=>"T058", :description=>"Health Care Activity"}, {:code=>"T120", :description=>"Chemical Viewed Functionally"}, {:code=>"T100", :description=>"Age Group"}, {:code=>"T104", :description=>"Chemical Viewed Structurally"}, {:code=>"T171", :description=>"Language"}, {:code=>"T032", :description=>"Organism Attribute"}, {:code=>"T095", :description=>"Self-help or Relief Organization"}, {:code=>"T078", :description=>"Idea or Concept"}, {:code=>"T090", :description=>"Occupation or Discipline"}, {:code=>"T167", :description=>"Substance"}, {:code=>"T068", :description=>"Human-caused Phenomenon or Process"}, {:code=>"T168", :description=>"Food"}, {:code=>"T028", :description=>"Gene or Genome"}, {:code=>"T014", :description=>"Reptile"}, {:code=>"T050", :description=>"Experimental Model of Disease"}, {:code=>"T045", :description=>"Genetic Function"}, {:code=>"T011", :description=>"Amphibian"}, {:code=>"T013", :description=>"Fish"}, {:code=>"T094", :description=>"Professional Society"}, {:code=>"T087", :description=>"Amino Acid Sequence"}, {:code=>"T066", :description=>"Machine Activity"}, {:code=>"T185", :description=>"Classification"}, {:code=>"T006", :description=>"Rickettsia or Chlamydia"}, {:code=>"T049", :description=>"Cell or Molecular Dysfunction"}, {:code=>"T008", :description=>"Animal"}, {:code=>"T051", :description=>"Event"}, {:code=>"T038", :description=>"Biologic Function"}, {:code=>"T194", :description=>"Archaeon"}, {:code=>"T086", :description=>"Nucleotide Sequence"}, {:code=>"T039", :description=>"Physiologic Function"}, {:code=>"T012", :description=>"Bird"}, {:code=>"T063", :description=>"Molecular Biology Research Technique"}, {:code=>"T017", :description=>"Anatomical Structure"}, {:code=>"T082", :description=>"Spatial Concept"}, {:code=>"T088", :description=>"Carbohydrate Sequence"}, {:code=>"T099", :description=>"Family Group"}, {:code=>"T001", :description=>"Organism"}, {:code=>"T075", :description=>"Research Device"}, {:code=>"T096", :description=>"Group"}, {:code=>"T016", :description=>"Human"}, {:code=>"T072", :description=>"Physical Object"}, {:code=>"T071", :description=>"Entity"}, {:code=>"T200", :description=>"Clinical Drug"}, {:code=>"T085", :description=>"Molecular Sequence"}, {:code=>"T077", :description=>"Conceptual Entity"}, {:code=>"T010", :description=>"Vertebrate"}, {:code=>"T203", :description=>"Drug Delivery Device"}, {:code=>"T021", :description=>"Fully Formed Anatomical Structure"}, {:code=>"T204", :description=>"Eukaryote"}]
  SEMANTIC_DICT = {}
  SEMANTIC_TYPES.each do |st|
    SEMANTIC_DICT[st[:code]] = st[:description]
  end


  def index
    @semantic_types_for_select = []
    SEMANTIC_DICT.each_pair do |code, description|
      @semantic_types_for_select << ["#{description} (#{code})", code]
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
    LOG.add :debug, "Retrieved #{annotations.length} annotations: #{Time.now - start}s"
    massage_annotations(annotations, options) unless annotations.empty?
    render :json => annotations
  end

private


  def massage_annotations(annotations, options)
    # Use the batch REST API to get all the annotated class prefLabels.
    # Return a hash of class @id:prefLabel items.
    classDetails = get_class_details(annotations, options[:semanticTypes])
    # TODO: Get this working when the REST batch service supports it.
    #ontNames = get_ontology_names(annotations)
    # Get the class details required for display, assume this is necessary
    # for every element of the annotations array because the API returns a set.
    # Replace the annotated class with simplified details.
    start = Time.now
    annotations2delete = []
    annotations.each do |a|
      ac_id = a['annotatedClass']['@id']
      details = classDetails[ac_id]
      if details.nil?
        LOG.add :debug, "Failed to get class details for: #{a['annotatedClass']['links']['self'] }"
        annotations2delete.push(ac_id)
      else
        a['annotatedClass'] = details  # Simplify the class info
        hierarchy2delete = []
        a['hierarchy'].each do |h|
          hc_id = h['annotatedClass']['@id']
          details = classDetails[hc_id]
          if details.nil?
            LOG.add :debug, "Failed to get class details for: #{h['annotatedClass']['links']['self']}"
            hierarchy2delete.push(hc_id)
          else
            h['annotatedClass'] = details  # Simplify the class info
          end
        end
        # Remove any hierarchy classes that fail to resolve details.
        a['hierarchy'].delete_if { |h| hierarchy2delete.include? h['annotatedClass']['@id'] }
      end
    end
    # Remove any annotations with annotated classes that fail to resolve details.
    annotations.delete_if { |a| annotations2delete.include? a['annotatedClass']['@id'] }
    LOG.add :debug, "Completed annotation modifications: #{Time.now - start}s"
  end


  def get_class_details(annotations, semanticTypes)
    # Use batch service to get class prefLabels
    classDetails = {}
    classList = []
    annotations.each do |a|
      cls_id = a['annotatedClass']['@id']
      ont_id = a['annotatedClass']['links']['ontology']
      classList.push({'class'=>cls_id, 'ontology'=>ont_id})
      a['hierarchy'].each do |h|
        hc_id = h['annotatedClass']['@id']
        classList.push({'class'=>hc_id, 'ontology'=>ont_id}) # must be same ontology for hierarchy
      end
    end
    # remove duplicates
    classSet = classList.to_set # get unique class:ontology set
    classList = classSet.to_a   # assume collection requires a list in batch call
    # make the batch call
    properties = (semanticTypes.empty? && 'prefLabel') || 'prefLabel,semanticType'
    call_params = {'http://www.w3.org/2002/07/owl#Class'=>{'collection'=>classList, 'include'=>properties}}
    response = get_batch_results(call_params)
    # Simplify the response data for the UI
    classResults = JSON.parse(response)
    classResults["http://www.w3.org/2002/07/owl#Class"].each do |cls|
      # TODO: Replace the get_ontology_details with a batch call.
      ont_details = get_ontology_details( cls['links']['ontology'] )
      next if ont_details.nil? # No display for annotations on any class outside the BioPortal ontology set.
      id = cls['@id']
      classDetails[id] = {
          '@id' => id,
          'ui' => cls['links']['ui'],
          'uri' => cls['links']['self'],
          'prefLabel' => cls['prefLabel'],
          'ontology' => ont_details,
      }
      unless semanticTypes.empty? || cls['semanticType'].nil?
        # Extract the semantic type descriptions that were requested.
        semanticTypeURI = 'http://bioportal.bioontology.org/ontologies/umls/sty/'
        semanticCodes = cls['semanticType'].map {|t| t.sub( semanticTypeURI, '') }
        requestedCodes = semanticCodes.map {|code| (semanticTypes.include? code and code) || nil }.compact
        requestedDescriptions = requestedCodes.map {|code| SEMANTIC_DICT[code] }.compact
        classDetails[id]['semanticType'] = requestedDescriptions
      else
        classDetails[id]['semanticType'] = []
      end
    end
    return classDetails
  end


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
        ont['uri'] = ont_uri  # TODO: Change to UI link.
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
    uri = URI.parse(uri)
    LOG.add :debug, "Annotator URI: #{uri}"
    begin
      response = open(uri, "Authorization" => "apikey token=#{get_apikey}").read
    rescue RestClient::Exception => error
      @retries ||= 0
      if @retries < 2
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
    rescue RestClient::Exception => error
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

