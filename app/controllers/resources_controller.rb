class ResourcesController < ApplicationController

  def show
    @concept =  DataAccess.getNode(params[:ontology],params[:id])
    @ontology = DataAccess.getOntology(params[:ontology])
    latest = @ontology.is_latest? ? true : false
  
    @resources = []
    @resources = OBDWrapper.gatherResources(@ontology.ontologyId,@concept,latest,@ontology.id)

    render :partial=> 'resources'
  end


  def details
    # rails passes params as strings not booleans, so we convert latest to a true boolean here
    latest = convert_boolean_param(params[:latest])
    
    @details = OBDWrapper.gatherResourcesDetails(params[:ontology],latest,params[:version_id],params[:id],params[:resource],params[:element])

    render :partial=>'details'
  end

  
  def page
    #@concept =  DataAccess.getNode(params[:versioned_id],params[:concept])
    #@ontology = DataAccess.getOntology(params[:versioned_id])
    
    # rails passes params as strings not booleans, so we convert latest to a true boolean here
    latest = convert_boolean_param(params[:latest])
    
    @resource = Resource.new
    @resource.shortname=params[:resource]

    # Checking for UMLS_CUI is not implemented properly here
    # Eventually, we will be making a call for RRF ontologies that will take the place of the
    # check below.
    #if(@concept.properties["UMLS_CUI"]!=nil)
    #  @resource = OBDWrapper.gatherResourcesCui(@concept)
    #else
      @resource = OBDWrapper.pageResources(params[:ontology],latest,params[:version_id],params[:concept],params[:resource],params[:resource_main_context],params[:start],params[:end])
    #end
    
    render :partial=> 'paged'
  end  

private

  ##
  # Converts param string to a true boolean value.
  ##
  def convert_boolean_param(latest_param)
    latest = latest_param.eql?("true") ? true : false
  end


end
