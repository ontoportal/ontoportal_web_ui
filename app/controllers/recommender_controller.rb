class RecommenderController < ApplicationController
  layout 'ontology'

  def index
  end

  def create
    text = params[:text]
    ontology_ids = params[:ontology_ids]

    # Default values for UI
    params[:hierarchy] = 5
    params[:normalization] = 2

    recommendations = DataAccess.createRecommendation(text, ontology_ids, params)

    render :json => recommendations
  end
end
