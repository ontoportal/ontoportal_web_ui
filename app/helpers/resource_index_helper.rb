require 'cgi'

module ResourceIndexHelper

  def resource_results(elements, resources_hash)
    @elements = elements
    @resources_hash = resources_hash
    # Sort resources alphabetically
    @elements.resources.sort! {|a,b| @resources_hash[a[:acronym]][:name] <=> @resources_hash[b[:acronym]][:name]}
    render :partial => 'resource_results'
  end

  def resources_info(resources, popular_concepts)
    @popular_concepts = popular_concepts
    @resources_for_info = resources.sort {|a,b| a[:name].downcase <=> b[:name].downcase}
    render :partial => 'resources_info'
  end

  def field_text(text, field_info)
    # Adapted from element_text for the new API data. (TODO: element_text could disappear if this works?)
    onts = field_info[:ontology]
    # onts is a list of ontologies associated with an element field.  It may be empty.
    # If it contains ontology data, it may contain an ontology id (int > 0) and we should return a link.
    # We'll resolve the link to a label using JS once the page loads.
    if !onts || onts.empty?
      h(text)
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
