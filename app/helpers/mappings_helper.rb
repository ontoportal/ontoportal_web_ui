module MappingsHelper

  RELATIONSHIP_URIS = {
    "http://www.w3.org/2004/02/skos/core" => "skos:",
    "http://www.w3.org/2000/01/rdf-schema" => "rdfs:",
    "http://www.w3.org/2002/07/owl" => "owl:",
    "http://www.w3.org/1999/02/22-rdf-syntax-ns" => "rdf:"
  }

  def get_short_id(uri)
    split = uri.split("#")
    name = split.length > 1 && RELATIONSHIP_URIS.keys.include?(split[0]) ? RELATIONSHIP_URIS[split[0]] + split[1] : uri
    "<a href='#{uri}' target='_blank'>#{name}</a>"
  end

  def init_new_form(ontology_from = nil, ontology_to = nil, concept_from = nil, concept_to = nil)
    ontology_from = ontology_from.nil? ? params[:ontology_from] : ontology_from
    ontology_to = ontology_to.nil? ? params[:ontology_to] : ontology_to
    concept_from = concept_from.nil? ? params[:conceptid_from] : concept_from
    concept_to = concept_to.nil? ? params[:conceptid_to] : concept_to

    @ontology_from = DataAccess.getOntology(ontology_from) rescue OntologyWrapper.new
    @ontology_to = DataAccess.getOntology(ontology_to) rescue OntologyWrapper.new
    @concept_from = DataAccess.getNode(@ontology_from.id, concept_from) rescue NodeWrapper.new
    @concept_to = DataAccess.getNode(@ontology_to.id, concept_to) rescue NodeWrapper.new
  end
end
