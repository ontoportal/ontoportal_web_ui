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
    
    recommendations_filtered = []
    recommendations.each do |rec|
      includes_group = DataAccess.getOntology(rec["virtualOntologyId"]).groups.include?(params[:group]) rescue false
      includes_category = DataAccess.getOntology(rec["virtualOntologyId"]).categories.include?(params[:category]) rescue false
      
      if !params[:group].nil? && includes_group && !recommendations_filtered.include?(rec)
        recommendations_filtered << rec
      end
      
      if !params[:category].nil? && includes_category && !recommendations_filtered.include?(rec)
        recommendations_filtered << rec
      end
    end
    
    recommendations_filtered = recommendations if recommendations_filtered.empty?
    
    render :json => recommendations_filtered
  end
end
