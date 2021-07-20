class FairScoreController < ApplicationController

  helper FairScoreHelper
  include FairScoreHelper
  def details_html
    get_fair
    render partial: 'details'
  end

  def details_json
    get_fair
    render json: @fair_scores_data
  end

  private

  def get_fair
    not_found if params[:ontologies].nil? || params[:ontologies].empty?
    ontologies = params[:ontologies]

    if ontologies.include? ","
      @fair_scores_data = create_fair_scores_data(get_fair_combined_score(ontologies), ontologies.split(',').length)
    elsif ontologies.eql? "all"
      @fair_scores_data = create_fair_scores_data(get_fair_combined_score(ontologies), get_fair_score(ontologies).keys.length)
    else
      @fair_scores_data = create_fair_scores_data(get_fair_combined_score(ontologies) , 1)
    end
  end
end