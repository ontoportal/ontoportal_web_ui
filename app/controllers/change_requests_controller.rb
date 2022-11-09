# frozen_string_literal: true

class ChangeRequestsController < ApplicationController
  def create_synonym
    @concept_label = params[:concept_label]
    @concept_id = params[:concept_id]
    @ont_acronym = params[:ont_acronym]
    @username = session[:user].username

    respond_to :js
  end

  def create
    ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ont_acronym]).first
    query_string = { display: 'notation,prefixIRI', display_links: false, display_context: false }
    concept = ontology.explore.single_class(query_string, params[:concept_id])

    # TODO: use a more standardized approach for CURIE generation
    params[:curie] =
      if concept.notation
        concept.notation
      elsif concept.prefixIRI
        concept.prefixIRI
      else
        params[:concept_id]
      end

    content = KGCL::IssueContentGenerator.call(params)
    @issue = IssueCreatorService.call(params[:ont_acronym], content[:title], content[:body])
    flash.now.notice = helpers.change_request_success_message if @issue['id'].present?

    respond_to :js
  end
end
