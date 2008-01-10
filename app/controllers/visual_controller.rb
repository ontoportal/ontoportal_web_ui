class VisualController < ApplicationController
  
  def jam
    @concept = params[:id].gsub("_",":")
    @ontology = params[:ontology]
  end
  
  
end
