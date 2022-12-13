module ConceptsHelper



  def concept_label(ont_id,cls_id)
    @ontology = LinkedData::Client::Models::Ontology.find(ont_id)
    @ontology ||= LinkedData::Client::Models::Ontology.find_by_acronym(ont_id).first
    ontology_not_found(ont_id) unless @ontology
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


  def concept_date(concept)
    date = concept.modified || concept.created
    Date.parse(date) if date
  end

  def sorted_by_date_url(page = 1, last_concept = nil)
    out = "/ajax/classes/date_sorted_list?ontology=#{@ontology.acronym}&page=#{page}"
    out += "&last_date=#{concept_date(last_concept)}" if last_concept
    out
  end

  def same_period?(year, month, date)
    return  false if date.nil?
    date = Date.parse(date.to_s)
    year.eql?(date.year) && month.eql?(date.strftime('%B'))
  end

  def concepts_li_list(concepts)
    out = ''
    concepts.each do  |concept|
      out += tree_link_to_concept(child: concept, ontology_acronym: @ontology.acronym, active_style: '')
    end
    out
  end


  def render_concepts_by_dates
    first_year, first_month_concepts = @concepts_year_month.shift
    first_month, first_concepts = first_month_concepts.shift
    out = ''
    if same_period?(first_year, first_month, @last_date)
      out += "<ul>#{concepts_li_list(first_concepts)}</ul>"
    else
      tmp = {}
      tmp[first_month] = first_concepts
      first_month_concepts = tmp.merge(first_month_concepts)
    end
    tmp = {}
    tmp[first_year] = first_month_concepts
    @concepts_year_month = tmp.merge(@concepts_year_month)

    @concepts_year_month.each do | year, month_concepts|
      month_concepts.each do |month , concepts|
        out += "<ul> #{month + ' ' + year.to_s}"
        out += concepts_li_list(concepts)
        out += "</ul>"
      end
    end

    raw out
  end
end
