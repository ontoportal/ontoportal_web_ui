

# TODO: Put these requires and the get_json method into a new annotator client
require 'json'
require 'open-uri'
require 'cgi'


class AnnotatorController < ApplicationController
  layout 'ontology'

  #REST_URL = "http://#{$REST_DOMAIN}"
  REST_URL = "http://stagedata.bioontology.org"
  ANNOTATOR_LOCATION = REST_URL + "/annotator"
  API_KEY = $API_KEY

  def index
    @semantic_types_for_select = []
    # TODO: Semantic types are disabled until the new API supports semantic types (May, 2013)
    # DISABLE OLD API CLIENT
    #annotator = get_annotator_client
    #annotator.semantic_types.each do |st|
    #  @semantic_types_for_select << [ "#{st[:description]} (#{st[:semanticType]})", st[:semanticType]]
    #end
    @semantic_types_for_select.sort! {|a,b| a[0] <=> b[0]}

    # TODO: Duplicate the filteredOntologyList for the LinkedData client?
    #ontology_ids = []
    #annotator.ontologies.each {|ont| ontology_ids << ont[:virtualOntologyId]}
    #@annotator_ontologies = DataAccess.getFilteredOntologyList(ontology_ids)
    @annotator_ontologies = LinkedData::Client::Models::OntologySubmission.all
  end

  def create
    text_to_annotate = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    ont_uris = params[:ontology_ids] ||= []
    ont_uris = ont_uris.empty? ? [] : params[:ontology_ids]  # Convert an empty string to an empty array, if required.
    options = { :ontologiesToKeepInResult => ont_uris,
                :withDefaultStopWords => true,
                :levelMax => params[:levelMax] ||= 0,
                :semanticTypes => params[:semanticTypes] ||= [],
                :mappingTypes => params[:mappingTypes] ||= [],
                :wholeWordOnly => params[:wholeWordOnly] ||= true,
                :isVirtualOntologyId => true
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
    query = ANNOTATOR_LOCATION
    query += "?text=" + CGI.escape(text_to_annotate)
    query += "&levelMax=" + options[:levelMax].to_s
    annotations = parse_annotator_json(query)
    LOG.add :debug, "Getting annotations: #{Time.now - start}s"

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

  # DISABLE THE OLD API CLIENT
  #def get_annotator_client
  #  # https://github.com/ncbo/ncbo_annotator_ruby_client
  #  options = {:apikey => $API_KEY, :annotator_location => "http://#{$REST_DOMAIN}/obs"}
  #  if session[:user]
  #    options[:apikey] = session[:user].apikey
  #  end
  #  NCBO::Annotator.new(options)
  #end

  def parse_annotator_json(url)
    apikey = API_KEY
    if session[:user]
      apikey = session[:user].apikey
    end
    JSON.parse(open(url, "Authorization" => "apikey token=#{apikey}").read)

  end




end

