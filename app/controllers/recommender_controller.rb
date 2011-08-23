class RecommenderController < ApplicationController
  layout 'ontology'

  def index
  end
  
  def create
    text = params[:text]
    ontology_ids = params[:ontology_ids]
    
    recommendations = DataAccess.createRecommendation(text, ontology_ids)
    
    render :json => recommendations
  end
end
