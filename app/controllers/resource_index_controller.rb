
# TODO: Put these requires and the get_json method into a new annotator client
require 'json'
require 'open-uri'
require 'cgi'
require 'rest-client'
require 'ontologies_api_client'

require 'pry'


class ResourceIndexController < ApplicationController
  include ActionView::Helpers::TextHelper

  layout 'ontology'

  RESOURCE_INDEX_URI = REST_URI + "/resource_index"
  RI_RESOURCES_URI = RESOURCE_INDEX_URI + "/resources"
  RI_ONTOLOGIES_URI = RESOURCE_INDEX_URI + "/ontologies"

  # Disable old code:
  # Resource Index annotation offsets rely on latin-1 character sets for the count to be right. So we set all responses as latin-1.
  #before_filter :set_encoding
  #RI_OPTIONS = {:apikey => $API_KEY, :resource_index_location => "http://#{$REST_DOMAIN}/resource_index/", :limit => 10, :mode => :intersection}

  def index

    @resources = parse_json(RI_RESOURCES_URI)
    # Note: REST API sorts by resourceId (acronym)
    #@resources.sort! {|a,b| a["resourceName"].downcase <=> b["resourceName"].downcase}

    # Resource Index ontologies - REST API filters them for those that are in the triple store.
    # Data structure is a list of linked data ontology models
    #{
    #  "acronym": "GEOSPECIES",
    #  "name": "GeoSpecies Ontology",
    #  "@id": "http://stagedata.bioontology.org/ontologies/GEOSPECIES",
    #  "@type": "http://data.bioontology.org/metadata/Ontology",
    #  "links": { ... },
    #  "@context": { ... },
    #}
    @ri_ontologies = LinkedData::Client::HTTP.get(RI_ONTOLOGIES_URI)
    # Extract ontology attributes for javascript
    @ont_ids = []
    @ont_acronyms = {}
    @ont_names = {}
    @ri_ontologies.each do |ont|
      acronym = ont.acronym.nil? && ont.name || ont.acronym
      @ont_acronyms[ont.id] = acronym
      @ont_names[ont.id] = ont.name
      @ont_ids.push ont.id
    end

  end

  def search
    if params[:q].nil?
      render :text => "No search term provided"
      return
    end
    # Filter on ontology_id
    params[:ontologies] = params[:ontology_ids]
    search_page = LinkedData::Client::Models::Class.search(params[:q], params)
    @results = search_page.collection
    render :text => @results.to_json
  end



  def resources_table
    params[:conceptids] = params[:conceptids].split(",")
    create()
  end


  def create
    #ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS))
    ranked_elements = ri.ranked_elements(params[:conceptids])

    # Sort by weight
    ranked_elements.resources.each do |resource|
      resource[:elements].each do |element|
        element[:weights].sort! {|a,b| b[:weight] <=> a[:weight]}
      end
    end

    @resources_hash = ri.resources_hash
    @elements = ranked_elements
    @elements.resources = convert_for_will_paginate(@elements.resources)
    @elements.resources.sort! {|a,b| @resources_hash[a.resourceId.downcase.to_sym][:resourceName].downcase <=> @resources_hash[b.resourceId.downcase.to_sym][:resourceName].downcase}
    @concept_ids = params[:conceptids]
    @bp_last_params = params

    render :partial => "resources_results"
  end


  def results_paginate
    #ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS))
    offset = (params[:page].to_i - 1) * params[:limit].to_i
    ranked_elements = ri.ranked_elements(params[:conceptids], :resourceids => [params[:resourceId]], :offset => offset, :limit => params[:limit])

    # There should be only one resource returned because we pass it in above
    @resource_results = convert_for_will_paginate(ranked_elements.resources)[0]
    @resources_hash = ri.resources_hash
    @concept_ids = params[:conceptids]

    render :partial => "resource_results"
  end


  def element_annotations
    #ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS.merge({:limit => 9999})))
    concept_ids = params[:conceptids].kind_of?(Array) ? params[:conceptids] : params[:conceptids].split(",")
    annotations = ri.element_annotations(params[:elementid], concept_ids, params[:resourceid])
    positions = {}
    annotations.annotations.each do |annotation|
      context = annotation.context
      positions[context[:contextName]] ||= []
      positions[context[:contextName]] << {:to => context[:to], :from => context[:from], :type => context[:contextType]}
    end

    render :json => positions
  end




private


  def convert_for_will_paginate(resources)
    resources_paginate = []
    resources.each do |resource|
      resources_paginate << ResourceIndexResultPaginatable.new(resource)
    end
    resources_paginate
  end


  def popular_concepts(ri)
    concepts = CACHE.get("ri_popular_concepts")
    if concepts.nil?
      concepts = ri.popular_concepts
      CACHE.set("ri_popular_concepts", concepts)
    end
    concepts
  end


  # Disable old code:
  #def set_encoding
  #  response.headers['Content-type'] = 'text/html; charset=ISO-8859-1'
  #end


  # Disable old code:
  #def set_apikey(ri)
  #  if session[:user]
  #    ri.options[:apikey] = session[:user].apikey
  #  else
  #    ri.options[:apikey] = $API_KEY
  #  end
  #  ri
  #end


end
