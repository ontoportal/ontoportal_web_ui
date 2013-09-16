class SubmissionsController < ApplicationController

  layout 'ontology'
  before_filter :authorize_and_redirect, :only=>[:edit,:update,:create,:new]

  def new
    @ontology = LinkedData::Client::Models::Ontology.get(CGI.unescape(params[:ontology_id]))
    @submission = LinkedData::Client::Models::OntologySubmission.new
  end

  def create
    # Make the contacts an array
    params[:submission][:contact] = params[:submission][:contact].values

    @submission = LinkedData::Client::Models::OntologySubmission.new(values: params[:submission])
    @ontology = LinkedData::Client::Models::Ontology.find(@submission.ontology)
    @submission_saved = @submission.save

    if @submission_saved.errors
      @errors = response_errors(@submission_saved)
      render "new"
    else
      # Adds ontology to syndication
      # Don't break here if we encounter problems, the RSS feed isn't critical
      # TODO_REV: What should we do about RSS / Syndication?
      # begin
      #   event = EventItem.new
      #   event.event_type="Ontology"
      #   event.event_type_id=@ontology.id
      #   event.ontology_id=@ontology.ontologyId
      #   event.save
      # rescue
      # end

      redirect_to "/ontologies/success/#{CGI.escape(@ontology.id)}"
    end
  end

  def edit
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first
    @submission = LinkedData::Client::Models::OntologySubmission.where {|sub| sub.ontology.id == @ontology.id && sub.submissionId == params[:id].to_i}.first
  end

  def update
    @ontology = LinkedData::Client::Models::Ontology.get(params[:submission][:ontology])
    @submission = LinkedData::Client::Models::OntologySubmission.where {|sub| sub.ontology.id == @ontology.id && sub.submissionId == params[:id].to_i}.first
    @submission.update_from_params(params[:submission])
    error_response = @submission.update

    if error_response
      @errors = response_errors(error_response)
    else
      # Adds ontology to syndication
      # Don't break here if we encounter problems, the RSS feed isn't critical
      # TODO_REV: What should we do about RSS / Syndication?
      # begin
      #   event = EventItem.new
      #   event.event_type="Ontology"
      #   event.event_type_id=@ontology.id
      #   event.ontology_id=@ontology.ontologyId
      #   event.save
      # rescue
      # end

      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

end