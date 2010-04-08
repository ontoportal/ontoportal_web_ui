module ConceptsHelper

  def include_relation?(relation_to_check)
    excluded_relations = [ "type", "rdf:type", "[R]", "SuperClass", "rdfs:subClassOf", "InstanceCount" ]
    excluded_relations.include?(relation_to_check)
  end

end
