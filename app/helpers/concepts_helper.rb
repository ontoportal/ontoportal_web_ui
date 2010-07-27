module ConceptsHelper

  def include_relation?(relation_to_check)
    excluded_relations = [ "type", "rdf:type", "[R]", "rdfs:subClassOf", "InstanceCount" ]

    excluded_relations.each do |relation|
      return true if relation_to_check.include?(relation)
    end
    return false
  end

end
