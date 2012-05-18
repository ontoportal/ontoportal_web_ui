class ResourceIndexController < ApplicationController
  layout 'ontology'

  RI_OPTIONS = {:apikey => $API_KEY, :resource_index_location => "http://#{$REST_DOMAIN}/resource_index/"}

  def index
  	ri = set_apikey(NCBO::ResourceIndex.new(RI_OPTIONS))
    ontologies = ri.ontologies
    ontology_ids = []
    ontologies.each {|ont| ontology_ids << ont[:virtualOntologyId]}

    @ontologies = DataAccess.getOntologyList
    @views = DataAccess.getViewList
    @onts_and_views = @ontologies | @views

    @semantic_types_for_select = []
    # semantic_types = annotator.semantic_types
    # @semantic_types_for_select = []
    # semantic_types.each do |semantic_type|
    #   @semantic_types_for_select << [ "#{semantic_type[:description]} (#{semantic_type[:semanticType]})", semantic_type[:semanticType]]
    # end
    # @semantic_types_for_select.sort! {|a,b| a[0] <=> b[0]}

    @ri_ontologies = DataAccess.getFilteredOntologyList(ontology_ids)
  end

private

  def set_apikey(ri)
    if session[:user]
      ri.options[:apikey] = session[:user].apikey
    else
      ri.options[:apikey] = $API_KEY
    end
    ri
  end

end
