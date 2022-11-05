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
    @issue = IssueCreatorService.call(params[:ont_acronym], content[:title], content[:body])
    if @issue['id'].present?
      flash.now.notice = helpers.change_request_success_message
    end

    respond_to do |format|
      format.js
    end
  end
end
