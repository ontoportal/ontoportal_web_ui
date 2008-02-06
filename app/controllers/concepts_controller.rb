class ConceptsController < ApplicationController
  # GET /concepts
  # GET /concepts.xml
   
  layout 'ontology'

  # GET /concepts/1
  # GET /concepts/1.xml
  def show
   
    @concept =  DataAccess.getNode(undo_param(params[:ontology]),params[:id])
      #@concept_id = params[:id] # Removed to see if even used
    
    @ontology = OntologyWrapper.new()
    @ontology.name = @concept.ontology_name
    if request.xhr?    
      show_ajax_request # process an ajax call
    else
      show_uri_request # process a full call
      render :file=> '/ontologies/visualize',:use_full_path =>true, :layout=>'ontology' # done this way to share a view
    end
  end

  
  # PRIVATE -----------------------------------------
  private
  
  def show_ajax_request
     case params[:callback]
        when 'load' # Load pulls in all the details of a node
          gather_details
          render :partial => 'load'
        when 'children' # Children is called only for drawing the tree
          @children =[]
          for child in @concept.children
            @children << TreeNode.new(child)
          end
          render :partial => 'childNodes'
      end    
  end
  
  def show_uri_request # gathers the full set of data for a node
    gather_details
    build_tree

  end
  
  def gather_details  #gathers the information for a node
    
     sids = [] #stores the thread IDs
    
    sids << spawn(:method => :thread) do  #threaded implementation to improve performance
      #builds the mapping tab
      @mappings = Mapping.find(:all, :conditions=>{:source_ont => @concept.ontology_name, :source_id => @concept.id},:include=>:user)    
      
      #builds the margin note tab
      @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @concept.ontology_name, :concept_id => @concept.id,:parent_id =>nil},:include=>:user)
      #needed to prepopulate the margin note
      @margin_note = MarginNote.new
      @margin_note.concept_id = @concept.id
      @margin_note.ontology_id = @concept.ontology_name
    end   
      
      @resources = []
    sids << spawn(:method => :thread) do   
       #Connects to the ontrez service to gather resources
                    
        if(@concept.properties["UMLS_CUI"]!=nil)
          #@resources = OntrezService.gatherResourcesCui(@concept.properties["UMLS_CUI"])
        else
          @resources = OBDWrapper.gatherResources(@ontology.to_param,@concept.id.gsub("_",":"))
        end
       
    end
    
    wait(sids) #waits for threads to finish
    
    update_tab(@ontology.name,@concept.id) #updates the 'history' tab with the current node
    
  end
  
  def build_tree
    #find path to root    
    path = @concept.path_to_root
    
    # create path and top nodes
    @root = TreeNode.new()
    @root.set_children(DataAccess.getTopLevelNodes(@concept.ontology_name))
    #find teh correct node to call children on
    expand_tree(@root.children,path)
    
  end
  
  def expand_tree(children_list, path_array) #recursively draws the tree
    #Pop actually removes the LAST item from the array
    target = path_array.pop
    found = false
    if target.nil?
      return
    end
    for child in children_list
      if child.id.eql?(target.id)
        found = true
        child.set_children(DataAccess.getChildNodes(child.ontology_name,child.id,nil))
        expand_tree(child.children,path_array)
      end
    end
    
    if !found #failsafe for a node that isnt considered a 'top node' e.g. Amino Acids Ontology
      expand_tree(children_list,path_array)
    end
    
  end
  
  
end
