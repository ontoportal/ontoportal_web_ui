class ConceptsController < ApplicationController
  # GET /concepts
  # GET /concepts.xml
   
  layout 'ontology'

  # GET /concepts/1
  # GET /concepts/1.xml
  def show
   
    @concept =  DataAccess.getNode(undo_param(params[:ontology]),params[:id])
    @concept_id = params[:id]
    @ontology = OntologyWrapper.new()
    @ontology.name = @concept.ontology_name
    if request.xhr?    
      show_ajax_request
    else
      show_uri_request
      render :file=> '/ontologies/visualize',:use_full_path =>true, :layout=>'ontology'
    end
  end

  
  # PRIVATE -----------------------------------------
  private
  
  def show_ajax_request
     case params[:callback]
        when 'load'
          gather_details
          render :partial => 'load'
        when 'children'
          @children =[]
          for child in @concept.children
            @children << TreeNode.new(child)
          end
          render :partial => 'childNodes'
      end    
  end
  
  def show_uri_request
    gather_details
    build_tree

  end
  
  def gather_details
    
     sids = []
    
    sids << spawn(:method => :thread) do
      #builds the mapping tab
      @mappings = Mapping.find(:all, :conditions=>{:source_ont => @concept.ontology_name, :source_id => @concept.id},:include=>:user)    
      @mappings_from = Mapping.find(:all, :conditions=>{:destination_ont => @concept.ontology_name, :destination_id => @concept.id},:include=>:user)
      
      
      #builds the margin note tab
      @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @concept.ontology_name, :concept_id => @concept.id,:parent_id =>nil},:include=>:user)
      @margin_note = MarginNote.new
      @margin_note.concept_id = @concept.id
      @margin_note.ontology_id = @concept.ontology_name
    end   
   
    sids << spawn(:method => :thread) do   
      @resources = []
      if(@concept.properties["UMLS_CUI"]!=nil)
        #@resources = OntrezService.gatherResourcesCui(@concept.properties["UMLS_CUI"])
      else
        @resources = OBDWrapper.gatherResources(param(@concept.ontology_name),@concept.id.gsub("_",":"))
      end
    end
    
    wait(sids)
    
    update_tab(@ontology.name,@concept.id)
    
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
  
  def expand_tree(children_list, path_array)
    #Pop actually removes the LAST item from the array
    puts "Path is #{path_array.inspect}"
    target = path_array.pop
    puts "Target is #{target}"
    found = false
    if target.nil?
      return
    end
    for child in children_list
      puts "Child #{child}"
      if child.id.eql?(target.id)
        found = true
        child.set_children(DataAccess.getChildNodes(child.ontology_name,child.id,nil))
        puts "Children Set for #{child.id} and they are #{child.children.inspect}"
        expand_tree(child.children,path_array)
      end
    end
    
    if !found
      expand_tree(children_list,path_array)
    end
    
  end
  
  
end
