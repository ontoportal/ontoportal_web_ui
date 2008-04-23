class ResourcesController < ApplicationController

  def show
     @concept =  DataAccess.getNode(undo_param(params[:ontology]),params[:id])
      puts @concept.inspect
       @ontology = OntologyWrapper.new()
       @ontology.name = @concept.ontology_name
       @resources = []

          if(@concept.properties["UMLS_CUI"]!=nil)
            @resources = OBDWrapper.gatherResourcesCui(@concept.properties["UMLS_CUI"])
          else
            @resources = OBDWrapper.gatherResources(@ontology.to_param,@concept.id.gsub("_",":"))
          end

  render :partial=> 'resources'
    
    
  end



end
