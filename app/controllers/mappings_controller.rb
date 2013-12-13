require 'cgi'
class MappingsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout 'ontology'
  before_filter :authorize_and_redirect, :only=>[:create,:new,:destroy]

  MAPPINGS_URL = "#{LinkedData::Client.settings.rest_url}/mappings"

  def index
    ontology_list = LinkedData::Client::Models::Ontology.all
    # TODO_REV: Views support for mappings
    # views_list = DataAccess.getViewList()

    ontologies_mapping_count = LinkedData::Client::HTTP.get("#{MAPPINGS_URL}/statistics/ontologies")

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

    counts = LinkedData::Client::HTTP.get("#{MAPPINGS_URL}/statistics/ontologies/#{params[:id]}")
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
    ontologies = [@ontology.acronym, @target_ontology.acronym]

    @mapping_pages = LinkedData::Client::HTTP.get(MAPPINGS_URL, {page: page, ontologies: ontologies.join(",")})
    @mappings = @mapping_pages.collection
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)

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
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontologyid]).first
    @concept = @ontology.explore.single_class({full: true}, params[:conceptid])

    @mappings = @concept.explore.mappings

    @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    render :partial => "mapping_table"
  end

  def new
    @ontology_from = LinkedData::Client::Models::Ontology.find(params[:ontology_from])
    @ontology_to = LinkedData::Client::Models::Ontology.find(params[:ontology_to])
    @concept_from = @ontology_from.explore.single_class({full: true}, params[:conceptid_from]) if @ontology_from
    @concept_to = @ontology_to.explore.single_class({full: true}, params[:conceptid_to]) if @ontology_to

    # Defaults just in case nothing gets provided
    @ontology_from ||= LinkedData::Client::Models::Ontology.new
    @ontology_to ||= LinkedData::Client::Models::Ontology.new
    @concept_from ||= LinkedData::Client::Models::Class.new
    @concept_to ||= LinkedData::Client::Models::Class.new

    if request.xhr? || params[:no_layout].eql?("true")
      render :layout => "none"
    else
      render :layout => "ontology"
    end
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    source_ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:map_from_bioportal_ontology_id]).first
    target_ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:map_to_bioportal_ontology_id]).first
    source = source_ontology.explore.single_class(params[:map_from_bioportal_full_id])
    target = target_ontology.explore.single_class(params[:map_to_bioportal_full_id])
    values = {
      terms: [
        {term: [source.id], ontology: source_ontology.id},
        {term: [target.id], ontology: target_ontology.id}
      ],
      creator: session[:user].id,
      relation: params[:mapping_relation],
      comment: params[:mapping_comment]
    }
    @mapping = LinkedData::Client::Models::Mapping.new(values: values)
    @mapping_saved = @mapping.save
    if @mapping_saved.errors
      raise Exception, @mapping_saved.errors
    else
      @delete_mapping_permission = check_delete_mapping_permission(@mapping_saved)
      render :json => @mapping_saved
    end
  end

  def destroy
    # ajax method, called from bp_mappings.js
    errors = []
    successes = []
    mapping_ids = params[:mappingids].split(",")
    mapping_ids.each do |map_id|
      begin
        # TODO: double check permission to delete mappings?
        #mapping = LinkedData::Client::Models::Mapping.find(map_id)
        #mapping.delete
        # NOTE: LinkedData::Client should automatically add the right API key.
        #map_uri = "#{MAPPINGS_URL}/#{CGI.escape(map_id)}?apikey=#{get_apikey}"
        map_uri = "#{MAPPINGS_URL}/#{CGI.escape(map_id)}"
        result = LinkedData::Client::HTTP.delete(map_uri)
        raise Exception if !result.nil? #&& result["errorCode"]
        successes << map_id
      rescue Exception => e
        errors << map_id
      end
    end
    # TODO: clear any cache that might contain mappings in successes.
    #ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontologyid]).first
    #concept_id = params[:conceptid].empty? ? "root" : params[:conceptid]
    #concept = ontology.explore.single_class(concept_id)
    #CACHE.delete("#{ontology.id}::#{CGI.escape(concept.id)}::map_page::page1::size100::params")
    #CACHE.delete("#{ontology.id}::#{CGI.escape(concept.id)}::map_count")
    render :json => { :success => successes, :error => errors }
  end

end
