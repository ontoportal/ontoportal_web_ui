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

  # a little method that returns true if the URIs array contain a gold:translation or gold:freeTranslation
  def is_translation(relation_array)
    relation_array.map!(&:downcase)
    if relation_array.include? "http://purl.org/linguistics/gold/translation"
      true
    elsif relation_array.include? "http://purl.org/linguistics/gold/freetranslation"
      true
    else
      false
    end
  end

  # method to get (using http) prefLabel for interportal classes
  def getInterportalPrefLabel(class_uri)
    json_class = JSON.parse(Net::HTTP.get(URI.parse("#{class_uri}?apikey=4a5011ea-75fa-4be6-8e89-f45c8c84844e")))
    if !json_class["prefLabel"].nil?
      prefLabel = json_class["prefLabel"]
    else
      prefLabel = nil
    end
    return prefLabel
  end

  # method to extract the prefLabel from the external class URI
  def getExternalPrefLabel(class_uri)
    if class_uri.include? "#"
      prefLabel = class_uri.split("#")[-1]
    else
      prefLabel = class_uri.split("/")[-1]
    end
    return prefLabel
  end

end
