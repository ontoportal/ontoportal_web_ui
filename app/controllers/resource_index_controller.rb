
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

  # Constants moved to the ApplicationController so they are available elsewhere too.
  #RESOURCE_INDEX_URI = REST_URI + "/resource_index"
  #RI_ELEMENT_ANNOTATIONS_URI = RESOURCE_INDEX_URI + "/element_annotations"
  #RI_ONTOLOGIES_URI = RESOURCE_INDEX_URI + "/ontologies"
  #RI_RANKED_ELEMENTS_URI = RESOURCE_INDEX_URI + "/ranked_elements"
  #RI_RESOURCES_URI = RESOURCE_INDEX_URI + "/resources"

  # Resource Index annotation offsets rely on latin-1 character sets for the count to be right. So we set all responses as latin-1.
  before_filter :set_encoding

  def index
    # Note: REST API sorts by resourceId (acronym)
    @resources = get_resource_index_resources # application_controller
    # Resource Index ontologies - REST API filters them for those that are in the triple store.
    # Data structure is a list of linked data ontology models
    @ri_ontologies = get_resource_index_ontologies # application_controller
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
    # Note: could be called by bp_resource_index.js - document-ready binding on #resource_index_classes;
    # however, the UI now calls the search controller at /search/json_search_ri
    if params[:q].nil?
      render :text => "No search class provided"
      return
    end
    search_page = LinkedData::Client::Models::Class.search(params[:q], params)
    @results = search_page.collection
    render :text => @results.to_json
  end

  def resources_table
    create()
  end

  def create
    @bp_last_params = params
    @classes = params[:classes]
    uri = getRankedElementsURI(params)
    @elements = []
    @elements_page_count = 0
    @error = nil
    while true
      begin
        # Resource index can be very slow and timeout, so parse_json includes one retry.
        ranked_elements_page = parse_json(uri) # See application_controller.rb
        #ranked_elements_page = LinkedData::Client::HTTP.get(uri)  ## DOESN'T WORK, MANGLES 'classes' params?
      rescue Exception => e
        @error = e.message
        LOG.add :error, @error
        break
      end
      # Might generate missing method exception here on a 404 response.
      @error = ranked_elements_page['error']
      if @error.nil?
        @elements.concat ranked_elements_page['collection']
        break if @elements_page_count >= ranked_elements_page['pageCount']
        break if ranked_elements_page['nextPage'].nil?
        uri = ranked_elements_page['nextPage']
        @elements_page_count += 1
      else
        LOG.add :error, @error
        break
      end
    end
    if @error.nil?
      # Sort ranked elements list by resource name
      @resources = get_resource_index_resources # application_controller
      @resources_hash = resources2hash(@resources)  # required in partial 'resources_results'
      resources_map = resources2map_id2name(@resources)
      @elements.sort! {|a,b| resources_map[a['resourceId']].downcase <=> resources_map[b['resourceId']].downcase}
      #@elements = convert_for_will_paginate(@elements)
    end
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

    @resources = get_resource_index_resources # application_controller
    @resources_hash = resources2hash(@resources)  # required in partial 'resources_results'

    @resource_results = convert_for_will_paginate(ranked_elements.resources)[0]
    @concept_ids = params[:conceptids]

    render :partial => "resource_results"
  end

  def element_annotations
    @annotations = []
    positions = {}
    @error = nil
    uri = RI_ELEMENT_ANNOTATIONS_URI +
        '?elements=' + params[:elementid] +
        '&resources=' + params[:resourceid] +
        '&' + params[:classes]
    begin
      # Resource index can be very slow and timeout, so parse_json includes one retry.
      @annotations = parse_json(uri) # See application_controller.rb
      # Removing HTTP.get because it mangles params in uri
      #@annotations = LinkedData::Client::HTTP.get(uri)
    rescue Exception => e
      @error = e.message
      LOG.add :error, @error
    end
    # Might generate missing method exception here on a 404 response.
    #binding.pry
    #@error = @annotations['error']  # not sure what this looks like on a 404 yet
    if @error.nil?
      @annotations.each do |a|
        field = a['elementField']
        positions[field] ||= []
        positions[field] << { :from => a['from'], :to => a['to'], :type => a['annotationType'] }
      end
    else
      LOG.add :error, @error
    end
    render :json => positions
  end


private


  def resources2hash(resourcesList)
    resources_hash = {}
    resourcesList.each do |r|
      # convert struct to hash (to_json will create a javascript object).
      resources_hash[r[:resourceId]] = struct_to_hash(r)
    end
    return resources_hash
  end

  def resources2map_id2name(resourcesList)
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

  def set_encoding
    response.headers['Content-type'] = 'text/html; charset=ISO-8859-1'
  end

end
