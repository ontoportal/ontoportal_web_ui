class SchemesController < ApplicationController
  include SchemesHelper

  def show
    @scheme = get_request_scheme
  end

  def show_label
    scheme  = get_request_scheme
    scheme_label =  scheme["prefLabel"] if scheme
    if scheme_label.nil? || scheme_label.empty?
      scheme_label = params[:id]
    end

    render plain: scheme_label
  end

  private

  def get_request_scheme
    params[:id] = params[:id] ? params[:id] : params[:scheme_id]

    if params[:id].nil? || params[:id].empty?
      render :text => "Error: You must provide a valid scheme id"
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology_id]).first
    not_found if @ontology.nil?
    get_scheme(@ontology.acronym, params[:id])
  end
end
