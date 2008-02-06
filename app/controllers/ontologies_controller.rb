require "set"
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
    @notes={}
    for ont in @ontologies
      note = MarginNote.find(:first,:conditions=>{:ontology_id => ont.name},:order=>'margin_notes.id desc',:include=>:user)

      unless note.nil?
        @notes[ont.name]=note
      end

    end
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
    
    sids = []
    
    #Set the ontology we are viewing
    @ontology = OntologyWrapper.new()
    @ontology.name = undo_param(params[:ontology])
    
   
        
      
      
      #get the top level nodes for the root
      @root = TreeNode.new()
      @root.set_children(@ontology.topLevelNodes)
      #get the initial concept to display
      @concept = DataAccess.getNode(@ontology.name,@root.children.first.id)
   
   
      sids << spawn(:method => :thread) do
        #gets the initial mappings
        @mappings =Mapping.find(:all, :conditions=>{:source_ont => @ontology.name, :source_id => @concept.id},:include=>:user)
        @mappings_from = Mapping.find(:all, :conditions=>{:destination_ont => @concept.ontology_name, :destination_id => @concept.id},:include=>:user)
        #gets the initial margin notes
        @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @ontology.name, :concept_id => @concept.id,:parent_id => nil},:include=>:user)
        @margin_note = MarginNote.new
        @margin_note.concept_id = @concept.id
        @margin_note.ontology_id = @ontology.name
        
        puts "---------------------------------"
        puts "Finished Gathering Database Info"
        puts "---------------------------------"
      end
      
      
      
      #gets the initial Ontrez Results
     
      @resources = []
      sids << spawn(:method => :thread) do
        if(@concept.properties["UMLS_CUI"]!=nil)
          #@resources = OntrezService.gatherResourcesCui(@concept.properties["UMLS_CUI"])
        else
          @resources = OBDWrapper.gatherResources(@ontology.to_param,@concept.id.gsub("_",":"))
        end
        
              puts "---------------------------------"
        puts "Finished Gathering Ontrez Info"
        puts "---------------------------------"
  
        
      end
      
            puts "---------------------------------"
        puts "Waiting......"
        puts "---------------------------------"
  
      wait(sids)
         
    update_tab(@ontology.name,@concept.id)
    
  
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
