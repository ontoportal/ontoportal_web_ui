# frozen_string_literal: true

class SubmissionsController < ApplicationController
  include SubmissionsHelper, SubmissionUpdater, OntologyUpdater

  layout :determine_layout
  before_action :authorize_and_redirect, only: [:edit, :update, :create, :new]

  # When getting "Add submission" form to display
  def new
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id], {include: 'all'}).first
    @submission = @ontology.explore.latest_submission || LinkedData::Client::Models::OntologySubmission.new
    @submission.id = nil
    @categories = LinkedData::Client::Models::Category.all
    @groups = LinkedData::Client::Models::Group.all
    @user_select_list = LinkedData::Client::Models::User.all(include: 'username').map { |u| [u.username, u.id] }
    @user_select_list.sort! { |a, b| a[1].downcase <=> b[1].downcase }
    @is_update_ontology = true
    render "ontologies/new"
  end

  # Called when form to "Add submission" is submitted
  def create
    @is_update_ontology = true

    if params[:ontology]
      @ontology, response = update_existent_ontology(params[:ontology_id])

      if response.nil? || response_error?(response)
        show_new_errors(response)
        return
      end
    end
    @submission = @ontology.explore.latest_submission({ display: 'all' })
    @submission = save_submission(new_submission_hash(@ontology, @submission))

    if response_error?(@submission)
      show_new_errors(@submission)
    else
      redirect_to "/ontologies/success/#{@ontology.acronym}"
    end
  end

  def edit
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first
    submissions = @ontology.explore.submissions
    @submission = submissions.select { |o| o.submissionId == params['id'].to_i }.first
  end

  def update
    # Make the contacts an array
    params[:submission][:contact] = params[:submission][:contact].values
    params[:submission][:contact].delete_if { |c| c[:name].empty? || c[:email].empty? }
    params[:submission][:naturalLanguage].compact_blank!

    @ontology = LinkedData::Client::Models::Ontology.get(params[:submission][:ontology])
    submissions = @ontology.explore.submissions
    @submission = submissions.select { |o| o.submissionId == params['id'].to_i }.first

    @submission.update_from_params(submission_params)
    # Update summaryOnly on ontology object
    @ontology.summaryOnly = @submission.isRemote.eql?('3')
    @ontology.update
    error_response = @submission.update(cache_refresh_all: false)
    if response_error?(error_response)
      @errors = response_errors(error_response) # see application_controller::response_errors
      render 'edit'
    else
      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  private

  def submission_params
    p = params.require(:submission).permit(:ontology, :description, :hasOntologyLanguage, :prefLabelProperty,
                                           :synonymProperty, :definitionProperty, :authorProperty, :obsoleteProperty,
                                           :obsoleteParent, :version, :status, :released, :isRemote, :pullLocation,
                                           :filePath, { contact: [:name, :email] }, :homepage, :documentation,
                                           :publication, naturalLanguage: [])
    p.to_h
  end
end
