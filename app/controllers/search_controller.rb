class SearchController < ApplicationController
  
  def index
    @ontologies = getOntologyList() # -- WebService
  end
  
  def concept
    puts params[:ontology]
    puts params[:name]
    @concepts = getNodeNameContains([undo_param(params[:ontology])],params[:name])
    puts "In Search Controller: #{@concepts}"
    for concept in @concepts
    puts "-----"
    puts concept
    puts "-----"
    puts concept.name
    puts concept.id
    end
    @ontology_name = undo_param(params[:ontology])
    render :partial => 'concepts'    
  end
  
  def concept_preview
    @concept = getNode(undo_param(params[:ontology]),params[:id])
    @children = @concept.children
    render :partial =>'concept_preview'
  end
  
end
