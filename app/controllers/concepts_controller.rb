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
      retry_link = "<a class='too_many_children_override' href='/ajax_concepts/#{params[:ontology]}/?conceptid=#{CGI.escape(params[:id])}&callback=children&too_many_children_override=true'>Get all terms</a>"
      render :text => "<div style='background: #eeeeee; padding: 5px; width: 80%;'>There are #{params[:child_size]} terms at this level. Retrieving these may take several minutes. #{retry_link}</div>"
      return
    elsif params[:callback].eql?('children') && params[:child_size].to_i > $MAX_POSSIBLE_DISPLAY && !too_many_children_override
      render :text => "<div style='background: #eeeeee; padding: 5px; width: 80%;'>There are #{params[:child_size]} terms at this level. Please use the \"Jump To\" to search for specific terms.</div>"
      return
    end

    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    @submission = @ontology.explore.latest_submission

    # TODO_REV: Support moving from archived to latest version
    # if @ontology.explore.latest_submission.submissionStatus == 6
    #   @latest_ontology = DataAccess.getLatestOntology(@ontology.ontologyId)
    #   params[:ontology] = @latest_ontology.id
    #   flash[:notice] = "The version of <b>#{@ontology.displayLabel}</b> you were attempting to view (#{@ontology.versionNumber}) has been archived and is no longer available for exploring. You have been redirected to the most recent version (#{@latest_ontology.versionNumber})."
    #   concept_id = params[:id] ? "?conceptid=#{params[:id]}" : ""
    #   redirect_to "/visualize/#{@latest_ontology.id}#{concept_id}", :status => :moved_permanently
    #   return
    # end

    @concept = @ontology.explore.single_class({full: true}, params[:id])

    if @concept.nil?
      raise Error404
    end

    if request.xhr?
      show_ajax_request # process an ajax call
    else
      show_uri_request # process a full call
      render :file => '/ontologies/visualize', :use_full_path => true, :layout => 'ontology'
    end
  end

  def show_label
    @ontology = LinkedData::Client::Models::Ontology.find(params[:ontology])
    begin
      term_label = @ontology.explore.single_class(params[:concept]).prefLabel
    rescue Exception => e
      term_label = "<span title='This term cannot be viewed because the id cannot be found in the most recent version of the ontology' style='cursor: help;'>#{params[:concept]}</span>"
    end
    render :text => term_label
  end

  def show_definition
    @ontology = DataAccess.getOntology(params[:ontology])
    term = DataAccess.getLightNode(@ontology.id, params[:concept])
    render :text => term.definitions
  end

  def show_tree
    view = false
    if params[:view]
      view = true
    end

    # Set the ontology we are viewing
    # TODO_REV: Handle ontology views
    if view
      @ontology = nil
    else
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end

    get_class(params)

    render :partial => "ontologies/treeview"
  end

  def virtual
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:conceptid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:ontologyid] : params[:ontology]

    if !params[:id].nil? && params[:id].empty?
      params[:id] = nil
    end

    @ontology = DataAccess.getLatestOntology(params[:ontology])
    @versions = DataAccess.getOntologyVersions(@ontology.ontologyId)
    unless params[:id].nil? || params[:id].empty?
      @concept = DataAccess.getNode(@ontology.id,params[:id])
    end

    if @ontology.metadata_only?
      redirect_to "/ontologies/#{@ontology.id}"
      return
    end

    if @ontology.statusId.to_i.eql?(3) && @concept
      LOG.add :info, 'show_virtual_concept', request, :virtual_id => @ontology.ontologyId, :ontology_name => @ontology.displayLabel, :concept_name => @concept.label, :concept_id => @concept.id
      redirect_to "/visualize/#{@ontology.id}/?conceptid=#{CGI.escape(@concept.id)}"
      return
    elsif @ontology.statusId.to_i.eql?(3)
      LOG.add :info, 'show_virtual', request, :virtual_id => @ontology.ontologyId, :ontology_name => @ontology.displayLabel
      redirect_to "/visualize/#{@ontology.id}"
      return
    else
      for version in @versions
        if version.statusId.to_i.eql?(3) && @concept
          LOG.add :info, 'show_virtual_concept', request, :virtual_id => @ontology.ontologyId, :ontology_name => @ontology.displayLabel, :concept_name => @concept.label, :concept_id => @concept.id
          redirect_to "/visualize/#{version.id}/?conceptid=#{CGI.escape(@concept.id)}"
          return
        elsif version.statusId.to_i.eql?(3)
          LOG.add :info, 'show_virtual', request, :virtual_id => @ontology.ontologyId, :ontology_name => @ontology.displayLabel
          redirect_to "/visualize/#{version.id}"
          return
        end
      end
      redirect_to "/ontologies/#{@ontology.id}"
      return
    end
  end

  # Renders a details pane for a given ontology/term
  def details
    raise Error404 if params[:conceptid].nil? || params[:conceptid].empty?
    @ontology = DataAccess.getOntology(params[:ontology])
    @concept = DataAccess.getNode(@ontology.id, params[:conceptid], params[:childrenlimit])

    if params[:styled].eql?("true")
      render :partial => "details", :layout => "partial"
    else
      render :partial => "details"
    end
  end

  def flexviz
    render :partial => "flexviz", :layout => "partial"
  end

  def exhibit
    time = Time.now
    #puts "Starting Retrieval"
    @concept =  DataAccess.getNode(params[:ontology],params[:id])
    #puts "Finished in #{Time.now- time}"

    string =""
    string << "{
           \"items\" : [\n
       	{ \n
       \"title\": \"#{@concept.label_html}\" , \n
       \"label\": \"#{@concept.id}\" \n"
    for property in @concept.properties.keys
      if @concept.properties[property].empty?
        next
      end

      string << " , "

      string << "\"#{property.gsub(":","")}\" : \"#{@concept.properties[property]}\"\n"

    end

    if @concept.children.length > 0
      string << "} , \n"
    else
      string << "}"
    end


    for child in @concept.children
      string << "{
         \"title\" : \"#{child.label_html}\" , \n
         \"label\": \"#{child.id}\"  \n"
      for property in child.properties.keys
        if child.properties[property].empty?
          next
        end

        string << " , "

        string << "\"#{property.gsub(":","")}\" : \"#{child.properties[property]}\"\n"
      end
      if child.eql?(@concept.children.last)
        string << "}"
      else
        string << "} , "
      end
    end

    response.headers['Content-Type'] = "text/html"

    string<< "]}"

    render :text=> string
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
    # TODO_REV: Support mappings for classes
    # @mappings = DataAccess.getConceptMappings(@concept.ontology.ontologyId, @concept.id)
    # TODO_REV: Support deleting mappings
    # check to see if user should get the option to delete
    # @delete_mapping_permission = check_delete_mapping_permission(@mappings)
    update_tab(@ontology, @concept.id) #updates the 'history' tab with the current node
  end

  def build_tree
    # find path to root
    rootNode = @concept.explore.tree(full: true)
    @root = LinkedData::Client::Models::Class.new(read_only: true)
    @root.children = rootNode unless rootNode.nil?
  end


end
