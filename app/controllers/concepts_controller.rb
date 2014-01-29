require 'cgi'

class ConceptsController < ApplicationController
  # GET /concepts
  # GET /concepts.xml

  layout 'ontology'

  # GET /concepts/1
  # GET /concepts/1.xml
  def show
    # Handle multiple methods of passing concept ids
    params[:id] = params[:id] ? params[:id] : params[:conceptid]
    too_many_children_override = params[:too_many_children_override].eql?("true")

    if params[:id].nil? || params[:id].empty?
      render :text => "Error: You must provide a valid concept id"
      return
    end

    if params[:callback].eql?('children') && params[:child_size].to_i > $MAX_CHILDREN && params[:child_size].to_i < $MAX_POSSIBLE_DISPLAY && !too_many_children_override
      retry_link = "<a class='too_many_children_override' href='/ajax_concepts/#{params[:ontology]}/?conceptid=#{CGI.escape(params[:id])}&callback=children&too_many_children_override=true'>Get all classes</a>"
      render :text => "<div style='background: #eeeeee; padding: 5px; width: 80%;'>There are #{params[:child_size]} classes at this level. Retrieving these may take several minutes. #{retry_link}</div>"
      return
    elsif params[:callback].eql?('children') && params[:child_size].to_i > $MAX_POSSIBLE_DISPLAY && !too_many_children_override
      render :text => "<div style='background: #eeeeee; padding: 5px; width: 80%;'>There are #{params[:child_size]} classes at this level. Please use the \"Jump To\" to search for specific classes.</div>"
      return
    end
    # Note that find_by_acronym includes views by default
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    # Get the latest 'ready' submission, or fallback to any latest submission
    # TODO: change the logic here if the fallback will crash the visualization
    @submission = get_ontology_submission_ready(@ontology)  # application_controller

    @concept = @ontology.explore.single_class({full: true}, params[:id])
    raise Error404 if @concept.nil?

    # TODO: convert 'disjointWith' parameters into classes
    # TODO: compare with concepts_helper::concept_properties2hash(properties)
    ## Try to resolve 'disjointWith' parameters into classes
    #@concept_properties = struct_to_hash(@concept.properties)
    #disjoint_key = @concept_properties.keys.map {|k| k if k.to_s.include? 'disjoint' }.compact.first
    #if not disjoint_key.nil?
    #  disjoint_val = @concept_properties[disjoint_key]
    #  if disjoint_val.instance_of? Array
    #    # Assume we have a list of class URIs that can be resolved by the batch service
    #    classes = disjoint_val.map {|cls| {:class => cls, :ontology => @ontology.id } }
    #  end
    #end

    if request.xhr?
      show_ajax_request # process an ajax call
    else
      show_uri_request # process a full call
      render :file => '/ontologies/visualize', :use_full_path => true, :layout => 'ontology'
    end
  end

  def show_label
    cls_id = params[:concept]   # cls_id should be a full URI
    ont_id = params[:ontology]  # ont_id could be a full URI or an acronym
    if ont_id.to_i > 0
      params_cleanup_new_api()
      stop_words = ["controller", "action"]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}", :status => :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find(ont_id)
    @ontology ||= LinkedData::Client::Models::Ontology.find_by_acronym(ont_id).first
    raise Error404 unless @ontology
    # Retrieve a class prefLabel or return the class ID (URI)
    # - mappings may contain class URIs that are not in bioportal (e.g. obo-xrefs)
    cls = @ontology.explore.single_class(cls_id)
    # TODO: log any cls.errors
    # TODO: NCBO-402 might be implemented here, but it throws off a lot of ajax result rendering.
    #cls_label = cls.prefLabel({:use_html => true}) || cls_id
    cls_label = cls.prefLabel || cls_id
    render :text => cls_label
  end

  def show_definition
    if params[:ontology].to_i > 0
      params_cleanup_new_api()
      stop_words = ["controller", "action"]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}", :status => :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find(params[:ontology])
    cls = @ontology.explore.single_class(params[:concept])
    render :text => cls.definition
  end

  def show_tree
    if params[:ontology].to_i > 0
      params_cleanup_new_api()
      stop_words = ["controller", "action"]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}", :status => :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    raise Error404 if @ontology.nil?
    get_class(params)   # application_controller
    render :partial => "ontologies/treeview"
  end

  def virtual
    if params[:ontology].to_i > 0
      acronym = BPIDResolver.id_to_acronym(params[:ontology])
      if acronym
        redirect_new_api(true)
        return
      end
    else
      redirect_to "/ontologies/#{params[:ontology]}?p=classes&#{params_string_for_redirect(params, prefix: "")}", :status => :moved_permanently
    end
  end

  # Renders a details pane for a given ontology/concept
  def details
    raise Error404 if params[:conceptid].nil? || params[:conceptid].empty?

    if params[:ontology].to_i > 0
      orig_id = params[:ontology]
      params_cleanup_new_api()
      options = {stop_words: ["controller", "action", "id"]}
      redirect_to "#{request.path.sub(orig_id, params[:ontology])}#{params_string_for_redirect(params, options)}", :status => :moved_permanently
      return
    end

    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    raise Error404 if @ontology.nil?

    @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
    raise Error404 if @concept.nil?

    if params[:styled].eql?("true")
      render :partial => "details", :layout => "partial"
    else
      render :partial => "details"
    end
  end

  def flexviz
    render :partial => "flexviz", :layout => "partial"
  end

  def biomixer
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    raise Error404 if @ontology.nil?

    @concept = @ontology.explore.single_class({full: true}, params[:conceptid])
    raise Error404 if @concept.nil?

    @immediate_load = true

    render partial: "biomixer", layout: false
  end

# PRIVATE -----------------------------------------
private

  def show_ajax_request
    case params[:callback]
    when 'load' # Load pulls in all the details of a node
      gather_details
      render :partial => 'load'
    when 'children' # Children is called only for drawing the tree
      @children = @concept.explore.children(full: true).collection || []
      @children.sort!{|x,y| (x.prefLabel || "").downcase <=> (y.prefLabel || "").downcase} unless @children.empty?
      render :partial => 'child_nodes'
    end
  end

  # gathers the full set of data for a node
  def show_uri_request
    gather_details
    build_tree
  end

  # gathers the information for a node
  def gather_details
    @mappings = @concept.explore.mappings
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)
    update_tab(@ontology, @concept.id) #updates the 'history' tab with the current node
  end

  def build_tree
    # find path to root
    rootNode = @concept.explore.tree(include: "prefLabel,childrenCount,obsolete")
    @root = LinkedData::Client::Models::Class.new(read_only: true)
    @root.children = rootNode unless rootNode.nil?
  end


end
