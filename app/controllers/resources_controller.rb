class ResourcesController < ApplicationController

  def show
     @concept =  DataAccess.getNode(params[:ontology],params[:id])
     @ontology = DataAccess.getOntology(params[:ontology])
    
       @resources = []
# Old ONtrez
        #  if(@concept.properties["UMLS_CUI"]!=nil)
        #    @resources = OBDWrapper.gatherResourcesCui(@concept)
        #  else
        #    @resources = OBDWrapper.gatherResources(to_param(@ontology.displayLabel),@concept)
        #  end
#New OBA

    @resources = OBDWrapper.gatherResources(@ontology.ontologyId,@concept)



  render :partial=> 'resources'
    
    
  end


  def details

    @details = OBDWrapper.gatherResourcesDetails(params[:ontology],params[:id],params[:resource],params[:element])
    
    render :partial=>'details'
  end

  
  def page
     @concept =  DataAccess.getNode(params[:ontology],params[:concept])
     @ontology = DataAccess.getOntology(params[:ontology])
    
       @resource = Resource.new
       @resource.shortname=params[:resource]

          if(@concept.properties["UMLS_CUI"]!=nil)
            @resource = OBDWrapper.gatherResourcesCui(@concept)
          else
            @resource = OBDWrapper.pageResources(@ontology.ontologyId,@concept.id,params[:resource],params[:start],params[:end])
          end

  render :partial=> 'paged'
    
  end  



end
