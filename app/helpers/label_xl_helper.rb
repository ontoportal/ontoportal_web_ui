module LabelXlHelper
  def label_xls_namespace(ontology_acronym, cls_id)
    "/ontologies/#{ontology_acronym}/classes/#{CGI.escape(cls_id)}/skos_xl_label"
  end

  def get_label_xl(ontology_acronym, cls_id, label_xl_uri)
    LinkedData::Client::HTTP
      .get("#{label_xls_namespace(ontology_acronym, cls_id)}/#{CGI.escape(label_xl_uri)}", { include: 'all' })
  end

  def get_label_xl_label(label_xl)
    if label_xl['literalForm'].nil? || label_xl['literalForm'].empty?
      extract_label_from(label_xl['@id']).html_safe
    else
      label_xl['literalForm']
    end
  end
end
