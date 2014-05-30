
require 'json'
require 'cgi'

class AnnotatorController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  ANNOTATOR_URI = REST_URI + "/annotator"

  def index
    @semantic_types_for_select = []
    @semantic_types ||= get_semantic_types
    @semantic_types.each_pair do |code, label|
      @semantic_types_for_select << ["#{label} (#{code})", code]
    end
    @semantic_types_for_select.sort! {|a,b| a[0] <=> b[0]}
    @annotator_ontologies = LinkedData::Client::Models::Ontology.all
  end


  def create
    params[:mappings] ||= []
    params[:max_level] ||= 0
    params[:ontologies] ||= []
    params[:semantic_types] ||= []
    text_to_annotate = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    options = { :ontologies => params[:ontologies],
                :max_level => params[:max_level].to_i,
                :semantic_types => params[:semantic_types],
                :mappings => params[:mappings],
                :longest_only => params[:longest_only],
                # :wholeWordOnly => params[:wholeWordOnly] ||= true,  # service default is true
                # :withDefaultStopWords => params[:withDefaultStopWords] ||= true,  # service default is true
    }
    start = Time.now
    query = ANNOTATOR_URI
    query += "?text=" + CGI.escape(text_to_annotate)
    query += "&include=prefLabel"
    query += "&max_level=" + options[:max_level].to_s
    query += "&ontologies=" + CGI.escape(options[:ontologies].join(',')) unless options[:ontologies].empty?
    query += "&semantic_types=" + options[:semantic_types].join(',') unless options[:semantic_types].empty?
    query += "&mappings=" + options[:mappings].join(',') unless options[:mappings].empty?
    query += "&longest_only=#{options[:longest_only]}"
    #query += "&wholeWordOnly=" + options[:wholeWordOnly].to_s unless options[:wholeWordOnly].empty?
    #query += "&withDefaultStopWords=" + options[:withDefaultStopWords].to_s unless options[:withDefaultStopWords].empty?
    annotations = parse_json(query) # See application_controller.rb
    #annotations = LinkedData::Client::HTTP.get(query)
    LOG.add :debug, "Retrieved #{annotations.length} annotations: #{Time.now - start}s"
    if annotations.empty? || params[:raw] == "true"
      # TODO: if params contains select ontologies and/or semantic types, only return those selected.
      response = {
          annotations: annotations,
          ontologies: get_simplified_ontologies_hash,  # application_controller
          semantic_types: get_semantic_types           # application_controller
      }
    else
      massage_annotated_classes(annotations, options)
      response = {
          annotations: annotations,
          ontologies: {},        # ontology data are in annotations already.
          semantic_types: {}     # semantic types are in annotations already.
      }
    end

    render :json => response
  end
end

