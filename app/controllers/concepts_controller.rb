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
    #builds the mapping tab
    @mappings = Mapping.find(:all, :conditions=>{:source_ont => @concept.ontology_name, :source_id => @concept.id},:include=>:user)
    
    #builds the margin note tab
    @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @concept.ontology_name, :concept_id => @concept.id,:parent_id =>nil},:include=>:user)
    @margin_note = MarginNote.new
    @margin_note.concept_id = @concept.id
    @margin_note.ontology_id = @concept.ontology_name
   
   # @resource = []
   # if(@concept.properties["UMLS_CUI"]!=nil)
   #  @resource = ResourceWrapper.gatherResourcesCui(@concept.properties["UMLS_CUI"])
   # else
   #    @resource = ResourceWrapper.gatherResources(@concept.id.gsub("_",":"),@concept.ontology_name)
   # end
    
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
    target = path_array.pop
    if target.nil?
      return
    end
    for child in children_list
      if child.id.eql?(target.id)
        child.set_children(DataAccess.getChildNodes(child.ontology_name,child.id,nil))
        expand_tree(child.children,path_array)
      end
    end
    
  end
  
  
end
