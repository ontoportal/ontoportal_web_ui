class SchemesController < ApplicationController
  include SchemesHelper

  def show
    params[:id] = params[:id] ? params[:id] : params[:scheme_id]

    if params[:id].nil? || params[:id].empty?
      render :text => "Error: You must provide a valid scheme id"
      return
    end

    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first
    not_found if @ontology.nil?
    @scheme = get_scheme(@ontology.acronym, params[:id])
  end
end
