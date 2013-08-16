require 'cgi'
class MappingsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout 'ontology'
  before_filter :authorize_and_redirect, :only=>[:create,:new,:destroy]

  def index
    binding.pry
    ontology_list = LinkedData::Client::Models::Ontology.all
    # TODO_REV: Views support for mappings
    # views_list = DataAccess.getViewList()

    ontologies_mapping_count = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}mappings/statistics/ontologies")

    ontologies_hash = {}
    ontology_list.each do |ontology|
      ontologies_hash[ontology.acronym] = ontology
    end

    # TODO_REV: Views support for mappings
    # views_list.each do |view|
    #   ontologies_hash[view.ontologyId] = view
    # end

    @options = {}
    ontologies_mapping_count.members.each do |ontology_acronym|
      ontology = ontologies_hash[ontology_acronym.to_s]
      mapping_count = ontologies_mapping_count[ontology_acronym]
      next unless ontology && mapping_count > 0
      select_text = "#{ontology.name} - #{ontology.acronym} (#{number_with_delimiter(mapping_count, delimiter: ',')})"
      @options[select_text] = ontology_acronym
    end

    @options = @options.sort
  end

  def count
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first

    counts = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}mappings/statistics/ontologies/#{params[:id]}")
    @ontologies_mapping_count = []
    counts.members.each do |acronym|
      count = counts[acronym]
      ontology = LinkedData::Client::Models::Ontology.find_by_acronym(acronym.to_s).first
      next unless ontology
      @ontologies_mapping_count << {'ontology' => ontology, 'count' => count}
    end
    @ontologies_mapping_count.sort! {|a,b| a['ontology'].name.downcase <=> b['ontology'].name.downcase } unless @ontologies_mapping_count.nil? || @ontologies_mapping_count.length == 0

    @ontology_id = @ontology.acronym
    @ontology_label = @ontology.name

    render :partial => 'count'
  end

  def show
    page = params[:page] || 1
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    @target_ontology = LinkedData::Client::Models::Ontology.find(params[:target])
    ontologies = [@ontology.id, @target_ontology.id]

    @mapping_pages = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}mappings", {page: page, ontologies: ontologies.join(",")})
    @mappings = @mapping_pages.collection

    if @mapping_pages.nil? || @mapping_pages.collection.empty?
      @mapping_pages = MappingPage.new
      @mapping_pages.page = 1
      @mapping_pages.pageCount = 1
    end

    total_results = @mapping_pages.pageCount * @mapping_pages.collection.length

    # This converts the mappings into an object that can be used with the pagination plugin
    @page_results = WillPaginate::Collection.create(@mapping_pages.page, @mapping_pages.collection.length, total_results) do |pager|
       pager.replace(@mapping_pages.collection)
    end

    render :partial => 'show'
  end

  def get_concept_table
    @ontology = DataAccess.getOntology(params[:ontologyid])
    @concept = DataAccess.getNode(@ontology.id, params[:conceptid])

    @mappings = DataAccess.getConceptMappings(@ontology.ontologyId, @concept.fullId)

    # check to see if user should get the option to delete
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    render :partial => "mapping_table"
  end

  def upload
    @ontologies = @ontologies = DataAccess.getOntologyList()
    @users = User.find(:all)
  end


  def process_mappings
     MappingLoader.processMappings(params)

     flash[:notice] = 'Mappings are processed'
     @ontologies = @ontologies = DataAccess.getOntologyList()
     @users = User.find(:all)
     render :action=>:upload
  end

  def new
    @ontology_from = DataAccess.getOntology(params[:ontology_from]) rescue OntologyWrapper.new
    @ontology_to = DataAccess.getOntology(params[:ontology_to]) rescue OntologyWrapper.new
    @concept_from = DataAccess.getNode(@ontology_from.id, params[:conceptid_from]) rescue NodeWrapper.new
    @concept_to = DataAccess.getNode(@ontology_to.id, params[:conceptid_to]) rescue NodeWrapper.new

    if request.xhr? || params[:no_layout].eql?("true")
      render :layout => "minimal"
    else
      render :layout => "ontology"
    end
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    source_ontology = DataAccess.getOntology(params[:map_from_bioportal_ontology_id])
    target_ontology = DataAccess.getOntology(params[:map_to_bioportal_ontology_id])
    source = DataAccess.getNode(source_ontology.id, params[:map_from_bioportal_full_id])
    target = DataAccess.getNode(target_ontology.id, params[:map_to_bioportal_full_id])
    comment = params[:mapping_comment]
    unidirectional = params[:mapping_bidirectional].eql?("false")
    relation = params[:mapping_relation]

    @mapping = DataAccess.createMapping(source.fullId, source.ontology.ontologyId, target.fullId, target.ontology.ontologyId, session[:user].id, comment, unidirectional, relation)

    # Adds mapping to syndication
    begin
      @mapping.each do |mapping|
        event = EventItem.new
        event.event_type= "Mapping"
        event.event_type_id = mapping.id
        event.ontology_id = mapping.source_ont
        event.save
      end
    rescue Exception => e
      LOG.add :debug, "Problem adding mapping to RSS feed"
    end

    render :json => @mapping
  end

  def destroy
    mapping_ids = params[:mappingids].split(",")
    concept_id = params[:conceptid].empty? ? "root" : params[:conceptid]

    ontology = DataAccess.getOntology(params[:ontologyid])
    concept = DataAccess.getNode(ontology.id, concept_id)
    concept = concept_id.eql?("root") ? concept.children[0] : concept

    errors = []
    successes = []
    mapping_ids.each do |map_id|
      begin
        result = DataAccess.deleteMapping(map_id)
        raise Exception if !result.nil? && result["errorCode"]
      rescue Exception => e
        errors << map_id
        next
      end
      successes << map_id
    end

    CACHE.delete("#{ontology.ontologyId}::#{CGI.escape(concept.fullId)}::map_page::page1::size100::params")
    CACHE.delete("#{ontology.ontologyId}::#{CGI.escape(concept.fullId)}::map_count")

    render :json => { :success => successes, :error => errors }
  end

end
