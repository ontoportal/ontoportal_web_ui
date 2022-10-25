module CollectionsHelper

  def collections_namespace(ontology_acronym)
    "/ontologies/#{ontology_acronym}/collections"
  end

  def get_collections(ontology_acronym, add_colors: false)
    collections = LinkedData::Client::HTTP
      .get(collections_namespace(ontology_acronym))

    generate_collections_colors(collections) if add_colors
    collections
  end

  def get_collection(ontology_acronym, collection_uri)
    LinkedData::Client::HTTP
      .get("#{collections_namespace(ontology_acronym)}/#{CGI.escape(collection_uri)}", { include: 'all' })
  end

  def get_collection_label(collection)
    if collection['prefLabel'].nil? || collection['prefLabel'].empty?
      extract_label_from(collection['@id']).html_safe
    else
      collection['prefLabel']
    end
  end

  def get_collections_labels(collections, main_uri = '')

    selected_label = nil
    collections_labels = []
    collections.each do  |x|
      id = x['@id']
      label = get_collection_label(x)
      if id.eql? main_uri
        selected_label = { 'prefLabel' => label, '@id' => id }
      else
        collections_labels.append( { 'prefLabel' => label, '@id' => id , 'color' => x['color'] })
      end
    end
    collections_labels.sort_by! { |s|  s['prefLabel']}
    collections_labels.unshift selected_label if selected_label
    [collections_labels, selected_label]
  end


  def collection_path(collection_id = '')
    "/ontologies/#{@ontology.acronym}/collections/show?id=#{escape(collection_id)}"
  end

  def request_collection_id
    params[:id] || params[:collection_id] || params[:concept_collection]
  end

  private

  def generate_collections_colors(collections)
    collections.each do |c|
      c.color = format('#%06x', (rand * 0xffffff))
    end
  end
end

