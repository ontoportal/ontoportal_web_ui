
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
  RI_RANKED_ELEMENTS_URI = RESOURCE_INDEX_URI + "/ranked_elements"
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
    # Note: could be called by bp_resource_index.js - document-ready binding on #resource_index_terms;
    # however, the UI now calls the REST API directly.
    if params[:q].nil?
      render :text => "No search term provided"
      return
    end
    # NOTE: the search API is not supporting 'ontologies' (Jul, 2013).
    search_page = LinkedData::Client::Models::Class.search(params[:q], params)
    @results = search_page.collection
    render :text => @results.to_json
  end


  def resources_table
    params[:classes] = params[:classes].split(",")
    create()
  end


  def create

    # NOTE: removed @classids, may crash partial.
    # TODO: fix partial for change to @classids, now @classes hash
    @classes = params[:classes]
    @bp_last_params = params

    uri = getRankedElementsURI(params)
    @elements = []
    while true
      begin
        ranked_elements_page = LinkedData::Client::HTTP.get(uri)
        @elements.concat ranked_elements_page['collection']
        break if ranked_elements_page.nextPage.nil?
        uri = ranked_elements_page.nextPage
      rescue Exception => e
        # TODO: log a meaningful message?
        raise e
      end
    end
    # Sort ranked elements list by resource name
    @resources = LinkedData::Client::HTTP.get(RI_RESOURCES_URI)
    @resources_hash = getResourcesHash(@resources)  # required in partial 'resources_results'
    resources_map = getResourcesMapId2Name(@resources)
    @elements.sort! {|a,b| resources_map[a.resourceId].downcase <=> resources_map[b.resourceId].downcase}

    # Sort by weight
    #@elements.each do |r|
    #  r[:elements].each do |element|
    #    element[:weights].sort! {|a,b| b[:weight] <=> a[:weight]}
    #  end
    #end

    @elements = convert_for_will_paginate(@elements)
    render :partial => "resources_results"
  end



  #
  #
  # TODO: Revise pagination to work with stagedata paged results object.
  # Note: the create() method gets all the paged results, see ranked_elements_page above.
  #
  #

  def results_paginate
    #ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS))
    offset = (params[:page].to_i - 1) * params[:limit].to_i
    ranked_elements = ri.ranked_elements(params[:conceptids], :resourceids => [params[:resourceId]], :offset => offset, :limit => params[:limit])

    # There should be only one resource returned because we pass it in above

    @resources = LinkedData::Client::HTTP.get(RI_RESOURCES_URI)
    @resources_hash = getResourcesHash(@resources)  # required in partial 'resources_results'

    @resource_results = convert_for_will_paginate(ranked_elements.resources)[0]
    @concept_ids = params[:conceptids]

    render :partial => "resource_results"
  end


  def element_annotations


    #binding.pry
    #
    #
    # TODO: Make a call to the new API search to get element annotations.
    #
    #
    #
    #uri = '?'
    #@annotations = LinkedData::Client::HTTP.get(uri)


    #ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS.merge({:limit => 9999})))
    #concept_ids = params[:classes].kind_of?(Array) ? params[:classes] : params[:classes].split(",")
    #annotations = ri.element_annotations(params[:elementid], concept_ids, params[:resourceid])
    positions = {}
    #annotations.annotations.each do |annotation|
    #  context = annotation.context
    #  positions[context[:contextName]] ||= []
    #  positions[context[:contextName]] << {:to => context[:to], :from => context[:from], :type => context[:contextType]}
    #end

    render :json => positions
  end




private


  def getResourcesHash(resourcesList)
    resources_hash = {}
    resourcesList.each do |r|
      resources_hash[r[:resourceId]] = r.to_h # convert struct to hash (to_json will create a javascript object).
    end
    return resources_hash
  end

  def getResourcesMapId2Name(resourcesList)
    resources_map = {}
    resourcesList.each do |r|
      resources_map[r[:resourceId]] = r[:resourceName]
    end
    return resources_map
  end

  def convert_for_will_paginate(resources)
    resources_paginate = []
    resources.each do |r|
      resources_paginate.push ResourceIndexResultPaginatable.new(r)
    end
    resources_paginate
  end

  def getRankedElementsURI(params)
    classesArgs = []
    if params[:classes].kind_of?(Hash)
      classesHash = params[:classes]
      classesHash.each do |ont_uri, cls_uris|
        classesStr = 'classes[' + CGI::escape(ont_uri) + ']='
        classesStr += CGI::escape( cls_uris.join(',') )
        classesArgs.push(classesStr)
      end
    end
    return RI_RANKED_ELEMENTS_URI + "?" + classesArgs.join('&')
  end

  # Disable old code:
  #def popular_concepts(ri)
  #  concepts = CACHE.get("ri_popular_concepts")
  #  if concepts.nil?
  #    concepts = ri.popular_concepts
  #    CACHE.set("ri_popular_concepts", concepts)
  #  end
  #  concepts
  #end

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
