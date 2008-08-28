class VisualController < ApplicationController
  
  def jam
    @concept = params[:id]
    @ontology = params[:ontology]
  end
  
  
end
