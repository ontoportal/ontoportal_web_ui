class MappingsController < ApplicationController
 

  # GET /mappings/new
  def new
    @mapping = Mapping.new
    @mapping.source_id = params[:source_id]
    @mapping.source_ont = undo_param(params[:ontology])
    @ontologies = DataAccess.getOntologyList() #populates dropdown
    @name = params[:source_name] #used for display
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    #creates mapping
    @mapping = Mapping.new(params[:mapping])
    @mapping.user_id = session[:user].id
    @mapping.save
    
    count = Mapping.count(:conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    CACHE.set("#{@mapping.source_ont.gsub(" ","_")}::#{@mapping.source_id}_MappingCount",count)
    
    
    #repopulates table
    @mappings =  Mapping.find(:all, :conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    @ontology = OntologyWrapper.new()
    @ontology.name = @mapping.source_ont
    render :partial =>'mapping_table'
     

  end

end
