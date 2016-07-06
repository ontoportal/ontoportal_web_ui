class SubmissionsController < ApplicationController

  layout 'ontology'
  before_action :authorize_and_redirect, :only=>[:edit,:update,:create,:new, :edit_metadata]

  def new
    @ontology = LinkedData::Client::Models::Ontology.get(CGI.unescape(params[:ontology_id])) rescue nil
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first unless @ontology
    @submission = @ontology.explore.latest_submission
    @submission ||= LinkedData::Client::Models::OntologySubmission.new
  end

  def create
    # Make the contacts an array
    params[:submission][:contact] = params[:submission][:contact].values

    @submission = LinkedData::Client::Models::OntologySubmission.new(values: params[:submission])
    @ontology = LinkedData::Client::Models::Ontology.find(@submission.ontology)
    @submission_saved = @submission.save
    if !@submission_saved || @submission_saved.errors
      @errors = response_errors(@submission_saved) # see application_controller::response_errors
      if @errors[:error][:uploadFilePath] && @errors[:error][:uploadFilePath].first[:options]
        @masterFileOptions = @errors[:error][:uploadFilePath].first[:options]
        @errors = ["Please select a main ontology file from your uploaded zip"]
      end
      render "new"
    else
      # Update summaryOnly on ontology object
      @ontology.summaryOnly = @submission.isRemote.eql?("3")
      @ontology.save
      redirect_to "/ontologies/success/#{@ontology.acronym}"
    end
  end

  def edit
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first
    submissions = @ontology.explore.submissions
    @submission = submissions.select {|o| o.submissionId == params["id"].to_i}.first
  end

  def update
    # Make the contacts an array
    params[:submission][:contact] = params[:submission][:contact].values

    @ontology = LinkedData::Client::Models::Ontology.get(params[:submission][:ontology])
    submissions = @ontology.explore.submissions
    @submission = submissions.select {|o| o.submissionId == params["id"].to_i}.first
    @submission.update_from_params(params[:submission])
    error_response = @submission.update

    # Update summaryOnly on ontology object
    @ontology.summaryOnly = @submission.isRemote.eql?("3")
    @ontology.save

    if error_response
      @errors = response_errors(error_response) # see application_controller::response_errors
    else
      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  ###
  # Controller of views/submission/edit_metadata.html.haml
  # When GET: retrieve metadata infos to display form
  # When POST: edit the submission metadata
  def edit_metadata

    if request.get?
      # Get the submission metadata from the REST API
      json_metadata = JSON.parse(Net::HTTP.get(URI.parse("#{REST_URI}/submission_metadata?apikey=#{API_KEY}")))
      @metadata = json_metadata

    elsif request.post?
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:acronym]).first
      submissions = @ontology.explore.submissions
      @submission = submissions.select {|o| o.submissionId == params["id"].to_i}.first

      puts "submission #{@submission.to_s}"

      # Get the list of extracted metadata
      json_metadata = JSON.parse(Net::HTTP.get(URI.parse("#{REST_URI}/submission_metadata?apikey=#{API_KEY}")))
      extracted_metadata_array = []
      json_metadata.each do |metadata|
        extracted_metadata_array << metadata["attribute"] if metadata["extracted"]
      end

      new_values = {}
      # For the moment just print in console and redirect to the same page
      params.each do |param|
        if extracted_metadata_array.include?(param[0])
          puts "param #{param}"
          if param.length > 0 && !param[1].nil? && !param[1].eql?("") && !param[0].eql?("deprecated")
            # TODO: enelever l'exception pour deprecated
            new_values[param[0].to_s] = param[1]
          end
        end
      end



      # Get list of ontologies in the portal
      ##json_ontologies = JSON.parse(Net::HTTP.get(URI.parse("#{REST_URI}/ontologies?apikey=#{API_KEY}")), {:symbolize_names => true})
      # JSON keys have been symbolized
=begin
      puts "REST uri #{REST_URI}"
      uri = URI.parse(REST_URI)
      http = Net::HTTP.new(uri.host, uri.port)

      # curl http://localhost9393/ontologies/AGROOE/latest_submission
      # curl -X PATCH -H "Content-Type: application/json" -H "Authorization: apikey token=1cfae05f-9e67-486f-820b-b393dec5764b" -d '{"notes": "teeest"}' http://localhost9393/ontologies/AGROOE/latest_submission

      req = Net::HTTP::Patch.new("#{REST_URI}/ontologies/#{params[:acronym].to_s}/latest_submission")
      req['Content-Type'] = "application/json"
      req['Authorization'] = "apikey token=#{API_KEY}"
      req.body = new_values.to_json

      puts "paaath /ontologies/#{params[:acronym].to_s}/submissions/#{params[:submissionId].to_s}"
      puts "jsoooon #{new_values.to_json}"

      response = http.start do |http|
        http.request(req)
      end

      puts "Response status : #{response.code} #{response.body}"
      puts " "

=end

      puts "new values #{new_values}"

      @submission.update_from_params(new_values)
      @submission.update
      @ontology.save
      #puts response.errors
      redirect_to "#{request.fullpath}"
      #redirect_to "#{"http://google.com"}"
    end
  end


end
