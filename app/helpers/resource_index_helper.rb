require 'cgi'

module ResourceIndexHelper

  def resource_results(elements, resources_hash)
    @elements = elements
    @resources_hash = resources_hash
    # Sort resources alphabetically
    @elements.resources.sort! {|a,b| @resources_hash[a[:resourceId]][:resourceName] <=> @resources_hash[b[:resourceId]][:resourceName]}
    render :partial => 'resource_results'
  end

  def resources_links(resources, resources_hash = {})
    @resources_for_links = resources
    @resources_for_select = []
    resources.each do |resource|
      resource_name = resource[:resourceName] ||= resources_hash[resource[:resourceId].downcase.to_sym][:resourceName] rescue "unknown"
      @resources_for_select << ["#{resource_name} (#{number_with_delimiter(resource[:totalElements] ||= resource[:totalResults], :delimiter => ",")} records)", resource[:resourceId]]
    end
    render :partial => 'resources_links'
  end

  def resources_info(resources, popular_concepts)
    @popular_concepts = popular_concepts
    @resources_for_info = resources.sort {|a,b| a[:resourceName].downcase <=> b[:resourceName].downcase}
    render :partial => 'resources_info'
  end

  def obs_concept_link(local_concept_id)
    split_id = local_concept_id.split("/")
    ontology_id = split_id[0]
    concept_id = split_id[1]
    "/ontologies/#{ontology_id}?p=terms&conceptid=#{CGI.escape(concept_id)}"
  end

  def element_text(element, weight)
    element_onts = element[:ontoIds]
    # element_onts contains information on whether a particular field is associated with an ontology
    # If it is, it will contain an ontology id (int > 0) and if it does we should return a link
    # We'll resolve the link to a label using JS once the page loads
    if element_onts[weight[:name]] > 0
      concept_ids = element[:text][weight[:name]].split("> ")
      concept_links = []
      concept_ids.each do |id|
        split_id = id.split("/")
        ontology_id = split_id[0]
        concept_id = split_id[1]
        href = "#{$UI_URL}/ontologies/#{ontology_id}?p=terms&conceptid=#{concept_id}"
        concept_links << "<a href='#{href}' class='ri_concept' data-ontology_id='#{ontology_id}' data-applied_label='false' data-concept_id='#{CGI.escape(concept_id)}'>view term in #{$SITE}</a>"
      end
      concept_links.join("<br/>")
    else
      h(element[:text][weight[:name]])
    end
  end

end
