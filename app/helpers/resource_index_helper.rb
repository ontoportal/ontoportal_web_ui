require 'cgi'

module ResourceIndexHelper

  def resource_results(elements, resources_hash)
    @elements = elements
    @resources_hash = resources_hash
    # Sort resources alphabetically
    @elements.resources.sort! {|a,b| @resources_hash[a[:acronym]][:name] <=> @resources_hash[b[:acronym]][:name]}
    render :partial => 'resource_results'
  end

  def resources_links(resources, resources_hash = {})
    @resources_for_links = resources
    @resources_for_select = []
    resources.each do |resource|
      resource_name = resource[:name] ||= resources_hash[resource[:acronym].downcase.to_sym][:name] rescue "unknown"
      @resources_for_select << ["#{resource_name} (#{number_with_delimiter(resource[:count] ||= resource[:totalResults], :delimiter => ",")} records)", resource[:acronym]]
    end
    render :partial => 'resources_links'   # TODO: WHERE IS THIS PARTIAL FILE?
  end

  def resources_info(resources, popular_concepts)
    @popular_concepts = popular_concepts
    @resources_for_info = resources.sort {|a,b| a[:name].downcase <=> b[:name].downcase}
    render :partial => 'resources_info'
  end

  def obs_concept_link(local_concept_id)
    split_id = local_concept_id.split("/")
    ontology_id = split_id[0]
    concept_id = split_id[1]
    "/ontologies/#{ontology_id}?p=classes&conceptid=#{CGI.escape(concept_id)}"
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
        href = "#{$UI_URL}/ontologies/#{ontology_id}?p=classes&conceptid=#{concept_id}"
        concept_links << "<a href='#{href}' class='ri_concept' data-ontology_id='#{ontology_id}' data-applied_label='false' data-concept_id='#{CGI.escape(concept_id)}'>view class in #{$SITE}</a>"
      end
      concept_links.join("<br/>")
    else
      h(element[:text][weight[:name]])
    end
  end

  def field_text(field)
    # Adapted from element_text for the new API data. (TODO: element_text could disappear if this works?)
    onts = field['associatedOntologies']
    # onts is a list of ontologies associated with an element field.  It may be empty.
    # If it contains ontology data, it may contain an ontology id (int > 0) and we should return a link.
    # We'll resolve the link to a label using JS once the page loads.
    if onts.empty?
      h(field['text'])
    else
      # TODO
      # TODO
      # TODO : modify this section of code when the API transforms data like this into something else:
      #"text"=> "1351/D020224> 1351/D019295> 1351/D008969> 1351/D001483> 1351/D017398> 1351/D000465> 1351/D005796> 1351/D008433> 1351/D009690> 1351/D005091",
      #
      # TODO: work with field[:associatedClasses]
      #
      concept_links = []
      #concept_ids = field.text.split("> ")
      #concept_ids.each do |id|
      #  split_id = id.split("/")
      #  ontology_id = split_id[0]
      #  concept_id = split_id[1]
      #  href = "#{$UI_URL}/ontologies/#{ontology_id}?p=classes&conceptid=#{concept_id}"
      #
      #  binding.pry
      #
      #  concept_links << "<a href='#{href}' class='ri_concept' data-ontology_id='#{ontology_id}' data-applied_label='false' data-concept_id='#{CGI::escape(concept_id)}'>view class in #{$SITE}</a>"
      #end
      concept_links.join("<br/>")
    end
  end
end
