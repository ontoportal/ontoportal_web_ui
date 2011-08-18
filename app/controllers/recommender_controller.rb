class RecommenderController < ApplicationController
  layout 'ontology'

  def index
    ontologies = DataAccess.getOntologyList
    groups = DataAccess.getGroups.to_a
    categories = DataAccess.getCategories

    @groups_for_select = []
    groups.each do |group|
      @groups_for_select << [ group[:name], group[:id] ]
    end
    
    @categories_for_select = []
    categories.each do |cat_id, cat|
      @categories_for_select << [ cat[:name], cat[:id] ]
    end

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
    ontology_ids = params[:ontology_ids]
    
    recommendations = DataAccess.createRecommendation(text, ontology_ids)
    
    render :json => recommendations
  end
end
