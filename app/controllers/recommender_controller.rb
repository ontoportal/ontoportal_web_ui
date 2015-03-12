class RecommenderController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  RECOMMENDER_URI = REST_URI + "/recommender"

  def index
  end

  def create
    # Parse params (default values are set at the service level)
    input = params[:input].strip.gsub("\r\n", " ").gsub("\n", " ")
    start = Time.now
    query = RECOMMENDER_URI
    query += "?input=" + CGI.escape(input)
    query += "&ontologies=" + CGI.escape(params[:ontologies].join(',')) unless params[:ontologies].nil?
    query += "&input_type=" + params[:input_type] unless params[:input_type].nil?
    query += "&output_type=" + params[:output_type] unless params[:output_type].nil?
    query += "&max_elements_set=" + params[:max_elements_set] unless params[:output_type].nil?
    query += "&wc=" + params[:wc].to_s unless params[:wc].nil?
    query += "&ws=" + params[:ws].to_s unless params[:ws].nil?
    query += "&wa=" + params[:wa].to_s unless params[:wa].nil?
    query += "&wd=" + params[:wd].to_s unless params[:wd].nil?
    recommendations = parse_json(query) # See application_controller.rb
    LOG.add :debug, "Retrieved #{recommendations.length} recommendations: #{Time.now - start}s"
    render :json => recommendations
  end

end
