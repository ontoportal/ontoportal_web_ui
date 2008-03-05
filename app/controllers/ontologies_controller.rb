require "set"
class OntologiesController < ApplicationController
 
  #caches_page :index
  
  helper :concepts  
  layout 'ontology'
  
  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
    
    @notes={} # Gets list of notes for the ontologies
    for ont in @ontologies
      #gets last note.. not the best way to do this
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
    @ontology = DataAccess.getOntology(undo_param(params[:ontology])) # shows the metadata    
  end


  # GET /visualize/:ontology
  def visualize
    
    sids = [] #holds the tread IDs
    
    #Set the ontology we are viewing
    @ontology = OntologyWrapper.new()
    @ontology.name = undo_param(params[:ontology])
    
   
        
      
      
      #get the top level nodes for the root
      @root = TreeNode.new()
      @root.set_children(@ontology.topLevelNodes)
      #get the initial concept to display
      @concept = DataAccess.getNode(@ontology.name,@root.children.first.id)
   
   
      sids << spawn(:method => :thread) do #threading to improve speed
        #gets the initial mappings
        @mappings =Mapping.find(:all, :conditions=>{:source_ont => @ontology.name, :source_id => @concept.id},:include=>:user)
        #@mappings_from = Mapping.find(:all, :conditions=>{:destination_ont => @concept.ontology_name, :destination_id => @concept.id},:include=>:user)
        #gets the initial margin notes
        @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @ontology.name, :concept_id => @concept.id,:parent_id => nil},:include=>:user)
        @margin_note = MarginNote.new
        @margin_note.concept_id = @concept.id
        @margin_note.ontology_id = @ontology.name
              
      end
      
      
      
    
     
      @resources = []
      sids << spawn(:method => :thread) do
        
        #gets the initial Ontrez Results          
        if(@concept.properties["UMLS_CUI"]!=nil)
          @resources = OBDWrapper.gatherResourcesCui(@concept.properties["UMLS_CUI"])
        else
          @resources = OBDWrapper.gatherResources(@ontology.to_param,@concept.id.gsub("_",":"))
        end        
      end
           
           
           
       # for demo only
       @software=[]
      if @ontology.name.eql?("Biomedical Resource Ontology")
        @software = NcbcSoftware.find(:all,:conditions=>{:ontology_label=>@concept.id})        
      end
      #------------------
           
  
      wait(sids) #wait for threads to finish
    unless @concept.id.empty?
    update_tab(@ontology.name,@concept.id) #update the tab with the current concept
    end
  
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @ontology.to_xml }
    end
  end

  
end
