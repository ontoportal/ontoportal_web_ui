module MappingsHelper

  RELATIONSHIP_URIS = {
    "http://www.w3.org/2004/02/skos/core" => "skos:",
    "http://www.w3.org/2000/01/rdf-schema" => "rdfs:",
    "http://www.w3.org/2002/07/owl" => "owl:"
  }

  def get_short_id(uri)
    split = uri.split("#")
    name = split.length > 1 ? RELATIONSHIP_URIS[split[0]] + split[1] : uri
    "<a href='#{uri}'>#{name}</a>"
  end

end
