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
    (scheme["prefLabel"] || extract_label_from(scheme["@id"])).html_safe
  end

  def get_schemes_labels(schemes, main_uri)
    schemes_labels = schemes.collect do |x|
      id = x["@id"]
      label = get_scheme_label(x)
      label = "#{label} (main)" if id.eql? main_uri
      [label,id]
    end
    selected = schemes.select { |x| x["@id"] == main_uri }.first
    selected_label = selected.nil? ? nil : [get_scheme_label(selected), selected["@id"]]

    [schemes_labels, selected_label]
  end

  def concept_label_to_show(submission: @submission_latest)
    submission.hasOntologyLanguage == 'SKOS' ? 'Concepts' : 'Classes'
  end
end
