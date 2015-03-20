class RecommenderController < ApplicationController
  layout 'ontology'

  # REST_URI is defined in application_controller.rb
  RECOMMENDER_URI = REST_URI + "/recommender"

  def index
  end

  def create
    start = Time.now
    uri = URI.parse(RECOMMENDER_URI)
    http = Net::HTTP.new(uri.host, uri.port)
    input = params[:input].strip.gsub("\r\n", " ").gsub("\n", " ")
    # Default values are set at the service level)
    form_data = Hash.new
    form_data['input'] = input
    form_data['ontologies'] = params[:ontologies].join(',') unless params[:ontologies].nil?
    form_data['input_type'] = params[:input_type] unless params[:input_type].nil?
    form_data['output_type'] = params[:output_type] unless params[:output_type].nil?
    form_data['max_elements_set'] = params[:max_elements_set] unless params[:output_type].nil?
    form_data['wc'] = params[:wc].to_s unless params[:wc].nil?
    form_data['ws'] = params[:ws].to_s unless params[:ws].nil?
    form_data['wa'] = params[:wa].to_s unless params[:wa].nil?
    form_data['wd'] = params[:wd].to_s unless params[:wd].nil?
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(form_data)
    result = http.request(request)
    recommendations = JSON.parse(result.body) # See application_controller.rb
    LOG.add :debug, "Retrieved #{recommendations.length} recommendations: #{Time.now - start}s"
    render :json => recommendations
  end

end
