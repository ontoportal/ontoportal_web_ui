class RecommenderController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  RECOMMENDER_URI = REST_URI + "/recommender"

  def index
  end

  def create
    # Set defaults
    params[:ontologies] ||= []
    params[:hierarchy] ||= 5
    params[:normalization] ||= 2
    # Parse params
    text = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    options = { :ontologies => params[:ontologies],
                :hierarchy => params[:hierarchy].to_i,
                :normalization => params[:normalization].to_i,
                #:max_level => params[:max_level].to_i ||= 0,
                #:semanticTypes => params[:semanticTypes] ||= [],
                #:mappings => params[:mappings] ||= [],
                #:wholeWordOnly => params[:wholeWordOnly] ||= true,  # service default is true
                #:withDefaultStopWords => params[:withDefaultStopWords] ||= true,  # service default is true
    }
    start = Time.now
    query = RECOMMENDER_URI
    query += "?text=" + CGI.escape(text)
    query += "&hierarchy=" + options[:hierarchy].to_s
    query += "&normalization=" + options[:normalization].to_s
    #query += "&max_level=" + options[:max_level].to_s
    query += "&ontologies=" + CGI.escape(options[:ontologies].join(',')) unless options[:ontologies].empty?
    #query += "&semanticTypes=" + options[:semanticTypes].join(',') unless options[:semanticTypes].empty?
    #query += "&mappings=" + options[:mappings].join(',') unless options[:mappings].empty?
    #query += "&wholeWordOnly=" + options[:wholeWordOnly].to_s unless options[:wholeWordOnly].empty?
    #query += "&withDefaultStopWords=" + options[:withDefaultStopWords].to_s unless options[:withDefaultStopWords].empty?
    recommendations = parse_json(query) # See application_controller.rb
    #recommendations = LinkedData::Client::HTTP.get(query)
    LOG.add :debug, "Retrieved #{recommendations.length} recommendations: #{Time.now - start}s"
    #
    #
    # TODO: get all the annotated class prefLabel values.
    # Modify the annotated classes (methods in application_controller.rb)
    #massage_annotated_classes(recommendations, options) unless recommendations.empty?
    # TODO: discard this code after handling the class prefLabels in above method
    recommendations.each {|r| r.delete 'annotatedClasses' }
    #
    #
    # Sort the recommendations by their rank (high scores are better)
    sorted = recommendations.sort {|a,b| a['score'] <=> b['score'] }.reverse
    # reduce data package size to suit reasonable display size
    sorted = sorted[0..24]
    # Get the ontology names
    ontologies_hash = get_simplified_ontologies_hash # method in application_controller.rb
    sorted.each {|r| r['ontology'] = ontologies_hash[ r['ontology']['@id'] ] }
    render :json => sorted
  end

end
