class MappingsController < ApplicationController
 

  # GET /mappings/new
  def new
    @mapping = Mapping.new
    @mapping.source_id = params[:source_id]
    @mapping.source_ont = undo_param(params[:ontology])
    @ontologies = DataAccess.getOntologyList()
    @name = params[:source_name]
  end

  # GET /mappings/1;edit
  #Not Implemented Yet
  def edit
    @mapping = Mapping.find(params[:id])
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    @mapping = Mapping.new(params[:mapping])
    @mapping.user_id = session[:user].id
    @mapping.save
    @mappings =  Mapping.find(:all, :conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    @ontology = OntologyWrapper.new()
    @ontology.name = @mapping.source_ont
    render :partial =>'mapping_table'
     

  end

  # PUT /mappings/1
  # PUT /mappings/1.xml
  #Not Implemented Yet
  def update
   
  end

  # DELETE /mappings/1
  # DELETE /mappings/1.xml
    #Not Implemented Yet
  def destroy
   
  end
end
