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

end
