class RecommenderController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  RECOMMENDER_URI = REST_URI + "/recommender"

  def index
  end

  def create

    text = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    options = { :ontologies => params[:ontologies] ||= [],
                :hierarchy => params[:hierarchy].to_i ||= 5,
                :normalization => params[:normalization].to_i ||= 2,
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

    #massage_recommendations(recommendations, options) unless recommendations.empty?

    render :json => recommendations
  end

  private


  def massage_recommendations(recommendations, options)
    # Get the class details required for display, assume this is necessary
    # for every element of the recommendations array because the API returns a set.
    # Use the batch REST API to get all the annotated class prefLabels.
    #start = Time.now
    #class_details = get_annotated_classes(recommendations, options[:semanticTypes])
    #simplify_annotated_classes(recommendations, class_details)
    #recommendations.each do |a|
    #  # repeat the simplification for each annotation hierarchy and mappings.
    #  simplify_annotated_classes(a['hierarchy'], class_details) if not a['hierarchy'].empty?
    #  simplify_annotated_classes(a['mappings'], class_details) if not a['mappings'].empty?
    #end
    LOG.add :debug, "Completed annotation modifications: #{Time.now - start}s"
  end

end
