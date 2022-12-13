module ConceptsHelper



  def concept_label(ont_id,cls_id)
    @ontology = LinkedData::Client::Models::Ontology.find(ont_id)
    @ontology ||= LinkedData::Client::Models::Ontology.find_by_acronym(ont_id).first
    not_found unless @ontology
    # Retrieve a class prefLabel or return the class ID (URI)
    # - mappings may contain class URIs that are not in bioportal (e.g. obo-xrefs)
    cls = @ontology.explore.single_class(cls_id)
    # TODO: log any cls.errors
    # TODO: NCBO-402 might be implemented here, but it throws off a lot of ajax result rendering.
    #cls_label = cls.prefLabel({:use_html => true}) || cls_id
    cls.prefLabel || cls_id
  end

  def concept_id_param_exist?(params)
    !(params[:conceptid].nil? || params[:conceptid].empty? || params[:conceptid].eql?("root") ||
      params[:conceptid].eql?("bp_fake_root"))
  end

  def get_concept_id(params, concept, root)
    if concept_id_param_exist?(params)
      concept.nil? ? '' : concept.id
    elsif !root.children.first.nil?
      root.children.first.id
    end
  end
  def concept_list_url(page = 1, collection_id, acronym)
    "/ajax/classes/list?ontology_id=#{acronym}&collection_id=#{collection_id}&page=#{page}"
  end
end
