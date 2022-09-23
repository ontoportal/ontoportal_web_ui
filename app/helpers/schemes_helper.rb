module SchemesHelper

  def schemes_namespace(ontology_acronym)
    "/ontologies/#{ontology_acronym}/schemes"
  end

  def get_schemes(ontology_acronym)
    LinkedData::Client::HTTP
      .get(schemes_namespace(ontology_acronym))
  end

  def get_scheme(ontology_acronym, scheme_uri)
    LinkedData::Client::HTTP
      .get("#{schemes_namespace(ontology_acronym)}/#{CGI.escape(scheme_uri)}", { include: 'all' })
  end

  def get_scheme_label(scheme)
    if scheme['prefLabel'].nil? || scheme['prefLabel'].empty?
      extract_label_from(scheme['@id']).html_safe
    else
      scheme['prefLabel']
    end
  end

  def get_schemes_labels(schemes, main_uri)

    selected_label = nil
    schemes_labels = []
    schemes.each do  |x|
      id = x['@id']
      label = get_scheme_label(x)
      if id.eql? main_uri
        label = "#{label} (main)" unless label.empty?
        selected_label = { 'prefLabel' => label, '@id' => id }
      else
        schemes_labels.append( { 'prefLabel' => label, '@id' => id })
      end
    end
    schemes_labels.sort_by! { |s|  s['prefLabel']}

    if selected_label
      schemes_labels.unshift selected_label
    end
    [schemes_labels, selected_label]
  end

  def concept_label_to_show(submission: @submission_latest)
    submission.hasOntologyLanguage == 'SKOS' ? 'Concepts' : 'Classes'
  end

  def section_name(section)
    if section.eql?('classes')
      concept_label_to_show
    else
      section.capitalize
    end
  end
end

