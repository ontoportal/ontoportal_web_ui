# frozen_string_literal: true

class ChangeRequestsController < ApplicationController
  def create_synonym
    @concept_label = params[:concept_label]
    @concept_id = params[:concept_id]
    @ont_acronym = params[:ont_acronym]
    @username = session[:user].username

    respond_to do |format|
      format.js
    end
  end

  def create
    content = KGCL::IssueContentGenerator.call(params)
    IssueCreatorService.call(params[:ont_acronym], content[:title], content[:body])
    head :ok
  end
end
