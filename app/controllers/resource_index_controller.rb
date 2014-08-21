
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
  RI_HIERARCHY_MAX_LEVEL='3'

  # Resource Index annotation offsets rely on latin-1 character sets for the count to be right. So we set all responses as latin-1.
  before_filter :set_encoding

  def index
    @resources ||= LinkedData::Client::ResourceIndex.resources
    @ri_ontologies = LinkedData::Client::Models::Ontology.all(include: "acronym,administeredBy,group,hasDomain,name,notes,projects,reviews,summaryOnly,viewingRestriction")
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

  def search_classes
    # check query
    if params[:q].nil?
      render :text => "No search class provided"
      return
    end
    params[:q] = params[:q].strip
    # Get the first 50 classes matching the query
    search_page = LinkedData::Client::Models::Class.search(params[:q], params)
    search_subset = search_page.collection[0...50]
    # Simplify search results and get ontology details
    classes_hash = simplify_classes( search_subset ) # application_controller
    # Get the simplified classes in the search order
    classes = search_subset.map {|cls| classes_hash[cls.id] }
    classes_json = classes.to_json
    if params[:response].eql?("json")
      classes_json = classes_json.gsub("\"","'")
      classes_json = "#{params[:callback]}({data:\"#{classes_json}\"})"
    end
    render :text => classes_json
  end

  def resources_table
    create()
  end

  def create
    @bp_last_params = params
    @classes = lookup_classes(params)
    @counts = LinkedData::Client::ResourceIndex.counts(@classes)

    @resources ||= LinkedData::Client::ResourceIndex.resources # application_controller
    @resources_hash ||= resources2hash(@resources)  # required in partial 'resources_results'

    render :partial => "resources_results"
  end

  def results_paginate
    params[:page]  ||= 1
    params[:limit] ||= 10
    @classes = lookup_classes(params)
    @documents = LinkedData::Client::ResourceIndex.documents(params[:acronym], @classes, page: params[:page], pagesize: params[:limit])
    @resource_results = ResourceIndexResultPaginatable.new(@documents)
    @acronym = params[:acronym]

    @resources ||= LinkedData::Client::ResourceIndex.resources
    @resources_hash ||= resources2hash(@resources)  # required in partial 'resources_results'

    render :partial => "resource_results"
  end

  def element_annotations
    @annotations = []
    positions = {}
    @error = nil
    uri = RI_ELEMENT_ANNOTATIONS_URI +
        '?elements=' + params[:elementid] +
        '&resources=' + params[:acronym] +
        '&' + params[:classes] +
        '&max_level=' + RI_HIERARCHY_MAX_LEVEL
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
      resources_hash[r[:acronym]] = struct_to_hash(r)
    end
    return resources_hash
  end

  def resources2map_id2name(resourcesList)
    resources_map = {}
    resourcesList.each do |r|
      resources_map[r[:acronym]] = r[:name]
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

  def getCountsURI(params)
    classesArgs = []
    if params[:classes].kind_of?(Hash)
      classesHash = params[:classes]
      classesHash.each do |ont_uri, cls_uris|
        classesStr = 'classes[' + CGI::escape(ont_uri) + ']='
        classesStr += CGI::escape( cls_uris.join(',') )
        classesArgs.push(classesStr)
      end
    end
    return "#{REST_URI}/resource_index/counts" + "?" + classesArgs.join('&')
  end

  def lookup_classes(params)
    classes = []
    if params[:classes].kind_of?(Hash)
      classesHash = params[:classes]
      classesHash.each do |ont_uri, cls_uris|
        cls_uris = cls_uris.is_a?(Array) ? cls_uris : [cls_uris]
        ont = LinkedData::Client::Models::Ontology.find(ont_uri)
        cls_uris.each {|cls_id| classes << ont.explore.single_class(cls_id)}
      end
    end
    return classes
  end

  def set_encoding
    response.headers['Content-type'] = 'text/html; charset=ISO-8859-1'
  end

end
