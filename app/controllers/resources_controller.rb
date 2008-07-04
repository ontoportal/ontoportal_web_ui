class ResourcesController < ApplicationController

  def show
     @concept =  DataAccess.getNode(params[:ontology],params[:id])
     @ontology = DataAccess.getOntology(params[:ontology])
      puts @concept.inspect
    
       @resources = []

          if(@concept.properties["UMLS_CUI"]!=nil)
            @resources = OBDWrapper.gatherResourcesCui(@concept)
          else
            @resources = OBDWrapper.gatherResources(to_param(@ontology.displayLabel),@concept)
          end

  render :partial=> 'resources'
    
    
  end



end
