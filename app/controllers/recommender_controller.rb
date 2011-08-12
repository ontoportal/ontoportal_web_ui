class RecommenderController < ApplicationController
  layout 'ontology'

  def index
    ontologies = DataAccess.getOntologyList

    @onts_for_select = []
    @onts_for_js = [];
    ontologies.each do |ont|
      abbreviation = ont.abbreviation.nil? ? "" : "(" + ont.abbreviation + ")"
      @onts_for_select << [ont.displayLabel.strip + " " + abbreviation, ont.ontologyId.to_i]
      @onts_for_js << "\"#{ont.displayLabel.strip} #{abbreviation}\": \"#{abbreviation.gsub("(", "").gsub(")", "")}\""
    end
    @onts_for_select.sort! { |a,b| a[0].downcase <=> b[0].downcase }
  end
  
  def create
    text = params[:text]
    
    recommendations = DataAccess.createRecommendation(text)
    
    render :json => recommendations
  end
end
