class FairScoreController < ApplicationController

  helper FairScoreHelper
  include FairScoreHelper
  def details
    not_found if params[:ontology].nil? || params[:ontology].empty?
    @ontology = params[:ontology]
    @fair_scores_data = create_fair_scores_data(get_fair_score(@ontology))
    render partial: 'details'
  end
end