class OntologiesController < ApplicationController
 
  #caches_page :index
  
  helper :concepts  
  layout 'ontology'
  
  # GET /ontologies
  # GET /ontologies.xml
  def index
 #   loadProtege()
   # @ontologies = Ontology.find(:all) -- Active Record
    @ontologies = DataAccess.getOntologyList() # -- WebService
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @ontologies.to_xml }
    end
  end
  
  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    @ontology = DataAccess.getOntology(undo_param(params[:ontology]))
    
  end


  # GET/ontologies/(id)/visualize
  def visualize
    #Set the ontology we are viewing
    @ontology = OntologyWrapper.new()
    @ontology.name = undo_param(params[:ontology])
    #get the top level nodes for the root
    @root = TreeNode.new()
    @root.set_children(@ontology.topLevelNodes)
    #get the initial concept to display
    @concept = DataAccess.getNode(@ontology.name,@root.children.first.id)
 
    #gets the initial mappings
    @mappings =Mapping.find(:all, :conditions=>{:source_ont => @ontology.name, :source_id => @concept.id},:include=>:user)
    
    #gets the initial margin notes
    @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @ontology.name, :concept_id => @concept.id,:parent_id => nil},:include=>:user)
    @margin_note = MarginNote.new
    @margin_note.concept_id = @concept.id
    @margin_note.ontology_id = @ontology.name
    
    
    
    
    #gets the initial Ontrez Results
    
    #@resource = []
    #if(@concept.properties["UMLS_CUI"]!=nil)   
    #  @resource = ResourceWrapper.gatherResourcesCui(@concept.properties["UMLS_CUI"])
    #else
    #    puts "---------looping through gather resource--------------"
    #   @resource = ResourceWrapper.gatherResources(@concept.id.gsub("_",":"),@concept.ontology_name)
    # end
    
    add_to_tab(@ontology,@concept)
    
  
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @ontology.to_xml }
    end
  end

  # GET /ontologies/new
  #not implemented
  def new
  
  end

  # GET /ontologies/1;edit
  #not implemented
  def edit
   
  end

  # POST /ontologies
  # POST /ontologies.xml
  #not implemented
  def create
    
  end

  # PUT /ontologies/1
  # PUT /ontologies/1.xml
  #not implemented
  def update
 
  end

  # DELETE /ontologies/1
  # DELETE /ontologies/1.xml
  #not implemented
  def destroy
   
  end
end
