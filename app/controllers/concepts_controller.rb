# frozen_string_literal: true

class ConceptsController < ApplicationController
  include MappingsHelper

  layout 'ontology'

  def show
    params[:id] = params[:id] || params[:conceptid]

    if params[:id].blank?
      render text: 'Error: You must provide a valid concept id'
      return
    end

    # find_by_acronym includes views by default
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    @ob_instructions = helpers.ontolobridge_instructions_template(@ontology)

    if request.xhr?
      display = params[:callback].eql?('load') ? { full: true } : { display: 'prefLabel' }
      @concept = @ontology.explore.single_class(display, params[:id])
      not_found if @concept.nil?
      show_ajax_request
    else
      render plain: 'Non-AJAX requests are not accepted at this URL', status: :forbidden
    end
  end

  def show_label
    cls_id = params[:concept]
    ont_id = params[:ontology]
    if ont_id.to_i.positive?
      params_cleanup_new_api
      stop_words = %w[controller action]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}",
                  status: :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find(ont_id)
    @ontology ||= LinkedData::Client::Models::Ontology.find_by_acronym(ont_id).first
    not_found unless @ontology
    # Retrieve a class prefLabel or return the class ID (URI)
    # - mappings may contain class URIs that are not in bioportal (e.g. obo-xrefs)
    cls = @ontology.explore.single_class(cls_id)
    # TODO: log any cls.errors
    # TODO: NCBO-402 might be implemented here, but it throws off a lot of ajax result rendering.
    # cls_label = cls.prefLabel({:use_html => true}) || cls_id
    cls_label = cls.prefLabel || cls_id
    render plain: cls_label
  end

  def show_definition
    if params[:ontology].to_i.positive?
      params_cleanup_new_api
      stop_words = %w[controller action]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}",
                  status: :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find(params[:ontology])
    cls = @ontology.explore.single_class(params[:concept])
    render text: cls.definition
  end

  def show_tree
    if params[:ontology].to_i.positive?
      params_cleanup_new_api
      stop_words = %w[controller action]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}",
                  status: :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    if @ontology.nil?
      not_found
    else
      get_class(params)
      render partial: 'ontologies/treeview'
    end
  end

  def property_tree
    if params[:ontology].to_i.positive?
      params_cleanup_new_api
      stop_words = %w[controller action]
      redirect_to "#{request.path}#{params_string_for_redirect(params, stop_words: stop_words)}",
                  status: :moved_permanently
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    not_found if @ontology.nil?
    @root = @ontology.property_tree
    render json: LinkedData::Client::Models::Property.properties_to_hash(@root.children)
  end

  def details
    not_found if params[:conceptid].blank?

    if params[:ontology].to_i.positive?
      orig_id = params[:ontology]
      params_cleanup_new_api
      options = { stop_words: %w[controller action id] }
      redirect_to "#{request.path.sub(orig_id, params[:ontology])}#{params_string_for_redirect(params, options)}",
                  status: :moved_permanently
      return
    end

    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    not_found if @ontology.nil?

    @concept = @ontology.explore.single_class({ full: true }, CGI.unescape(params[:conceptid]))
    not_found if @concept.nil?

    if params[:styled].eql?('true')
      render partial: 'details', layout: 'partial'
    else
      render partial: 'details'
    end
  end

  def biomixer
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    not_found if @ontology.nil?

    @concept = @ontology.explore.single_class({ full: true }, params[:conceptid])
    not_found if @concept.nil?

    @immediate_load = true

    render partial: 'biomixer', layout: false
  end

  private

  def show_ajax_request
    case params[:callback]
    when 'load' # Load pulls in all the details of a node
      gather_details
      render partial: 'load'
    when 'children' # Children is called only for drawing the tree
      @children = @concept.explore.children(pagesize: 750).collection || []
      @children.sort! { |x, y| (x.prefLabel || '').downcase <=> (y.prefLabel || '').downcase } unless @children.empty?
      render partial: 'child_nodes'
    end
  end

  def gather_details
    @mappings = get_concept_mappings(@concept)
    @notes = @concept.explore.notes
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)
    update_tab(@ontology, @concept.id) # updates the 'history' tab with the current node
  end
end
