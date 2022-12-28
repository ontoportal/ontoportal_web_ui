class SubmissionsController < ApplicationController
  include SubmissionsHelper
  layout :determine_layout
  before_action :authorize_and_redirect, :only => [:edit, :update, :create, :new]
  before_action :submission_metadata, only: [:create, :edit, :new, :update]

  # When getting "Add submission" form to display
  def new
    @ontology = LinkedData::Client::Models::Ontology.get(CGI.unescape(params[:ontology_id])) rescue nil
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first unless @ontology
    @submission = @ontology.explore.latest_submission
    @submission ||= LinkedData::Client::Models::OntologySubmission.new
  end

  # Called when form to "Add submission" is submitted
  def create
    # Make the contacts an array
    params[:submission][:contact] = params[:submission][:contact].values

    # Convert metadata that needs to be integer to int
    @metadata.map do |hash|
      if hash["enforce"].include?("integer")
        if !params[:submission][hash["attribute"]].nil? && !params[:submission][hash["attribute"]].eql?("")
          params[:submission][hash["attribute"].to_s.to_sym] = Integer(params[:submission][hash["attribute"].to_s.to_sym])
        end
      end
      if hash["enforce"].include?("boolean") && !params[:submission][hash["attribute"]].nil?
        if params[:submission][hash["attribute"]].eql?("true")
          params[:submission][hash["attribute"].to_s.to_sym] = true
        elsif params[:submission][hash["attribute"]].eql?("false")
          params[:submission][hash["attribute"].to_s.to_sym] = false
        else
          params[:submission][hash["attribute"].to_s.to_sym] = nil
        end
      end
    end

    @submission = LinkedData::Client::Models::OntologySubmission.new(values: submission_params)
    @ontology = LinkedData::Client::Models::Ontology.get(params[:submission][:ontology])
    
    # Update summaryOnly on ontology object
    @ontology.summaryOnly = @submission.isRemote.eql?("3")
    @ontology.update
    
    @submission_saved = @submission.save(cache_refresh_all: false)
    if response_error?(@submission_saved)
      @errors = response_errors(@submission_saved) # see application_controller::response_errors

      if @errors[:error][:uploadFilePath]
        @errors = ["Please specify the location of your ontology"]
      elsif @errors[:error][:contact]
        @errors = ["Please enter a contact"]
      end

      render "new"
    else
      redirect_to "/ontologies/success/#{@ontology.acronym}"
    end
  end

  # Called when form to "Edit submission" is submitted
  def edit
    latest_submission_attributes params[:ontology_id], params[:properties]&.split(','), required: params[:required]&.eql?('true'),
                                 show_sections: params[:show_sections]&.eql?('false'),
                                 inline_save: params[:inline_save]&.eql?('true')
  end

  # When editing a submission (called when submit "Edit submission information" form)
  def update
    error_responses = []
    params[:submission].each do |key, submission_params|
      error_responses << update_submission(submission_params)
    end

    if error_responses.compact.any? { |x| x.status != 204 }
      @errors = error_responses.map { |error_response| response_errors(error_response) }
    else
      if params[:attribute]
        render_submission_attribute(params[:attribute])
      else
        redirect_to  || "/ontologies/#{@ontology.acronym}"
      end
    end

  end

  private

  def update_submission(submission)
    unless submission[:contact].nil?
      submission[:contact] = submission[:contact].values
      submission[:contact].delete_if { |c| c[:name].empty? || c[:email].empty? }
    end

    @ontology = LinkedData::Client::Models::Ontology.get(submission[:ontology])

    @submission = @ontology.explore.submissions({ display: 'all' }, submission[:id])

    # Convert metadata that needs to be integer to int
    @metadata.map do |hash|
      if hash["enforce"].include?("integer")
        if !submission[hash["attribute"]].nil? && !submission[hash["attribute"]].eql?("")
          submission[hash["attribute"].to_s.to_sym] = Integer(submission[hash["attribute"].to_s.to_sym])
        end
      end
      if hash["enforce"].include?("boolean") && !submission[hash["attribute"]].nil?
        if submission[hash["attribute"]].eql?("true")
          submission[hash["attribute"].to_s.to_sym] = true
        elsif submission[hash["attribute"]].eql?("false")
          submission[hash["attribute"].to_s.to_sym] = false
        else
          submission[hash["attribute"].to_s.to_sym] = nil
        end
      end
    end
    @submission.update_from_params(submission_params(submission))
    # Update summaryOnly on ontology object
    @ontology.summaryOnly = @submission.isRemote.eql?('3')
    @ontology.update
    error_response = @submission.update(cache_refresh_all: false)
    if response_error?(error_response)
      @errors = response_errors(error_response) # see application_controller::response_errors
    else
      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  def submission_params(params)
    attributes = helpers.submission_attributes

    @metadata.each do |m|

      m_attr = m["attribute"].to_sym

      attributes << if m["enforce"].include?("list")
                      { m_attr => [] }
                    else
                      m_attr
                    end
    end

    p = params.permit(attributes.uniq)
    p.to_h.transform_values do |v|
      if v.is_a? Array
        v.reject(&:empty?)
      else
        v
      end
    end
  end

end
