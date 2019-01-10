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

  def onts_and_views_for_select
    @onts_and_views_for_select = []
    ontologies = LinkedData::Client::Models::Ontology.all(include: "acronym,name", include_views: true)
    ontologies.each do |ont|
      next if (ont.acronym.nil? || ont.acronym.empty?)
      ont_acronym = ont.acronym
      ont_display_name = "#{ont.name.strip} (#{ont_acronym})"
      @onts_and_views_for_select << [ont_display_name, ont_acronym]
    end
    @onts_and_views_for_select.sort! { |a,b| a[0].downcase <=> b[0].downcase }
    return @onts_and_views_for_select
  end

  def get_concept_mappings(concept)
    mappings = concept.explore.mappings
    # Remove mappings where the destination class exists in an ontology that the logged in user doesn't have permissions to view.
    # Workaround for https://github.com/ncbo/ontologies_api/issues/52.
    mappings.delete_if do |mapping|
      mapping.classes.reject! { |cls| (cls.id == concept.id) && (cls.links['ontology'] == concept.links['ontology']) }
      ont = mapping.classes[0].explore.ontology
      ont.errors && ont.errors.grep(/Access denied/).any?
    end
  end

end
