class RecommenderController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  RECOMMENDER_URI = REST_URI + "/recommender"

  def index
  end

  def create

    text = params[:text].strip.gsub("\r\n", " ").gsub("\n", " ")
    options = { :ontologies => params[:ontologies] ||= "",
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
    query += "&ontologies=" + CGI.escape(options[:ontologies]) unless options[:ontologies].empty?
    #query += "&semanticTypes=" + options[:semanticTypes].join(',') unless options[:semanticTypes].empty?
    #query += "&mappings=" + options[:mappings].join(',') unless options[:mappings].empty?
    #query += "&wholeWordOnly=" + options[:wholeWordOnly].to_s unless options[:wholeWordOnly].empty?
    #query += "&withDefaultStopWords=" + options[:withDefaultStopWords].to_s unless options[:withDefaultStopWords].empty?

    recommendations = parse_json(query) # See application_controller.rb
    #recommendations = LinkedData::Client::HTTP.get(query)
    LOG.add :debug, "Retrieved #{recommendations.length} recommendations: #{Time.now - start}s"
    # Modify the annotated classes (methods in application_controller.rb)
    massage_annotated_classes(recommendations, options) unless recommendations.empty?

    binding.pry

    sorted = recommendations.sort {|a,b| a['numTermsMatched'] <=> b['numTermsMatched'] }.reverse
    # Reduce the data package sent to the browser (via ajax)
    #simple = sorted.map {|r| [r['score'], r['ontology']['acronym'], r["numTermsMatched"], r["numTermsTotal"]] }


    # reduce data package size to suit reasonable display size
    render :json => sorted[0..24]
  end

end
