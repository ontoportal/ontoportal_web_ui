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
      return h(text)
    else
      concept_links = []
      text = text.is_a?(Array) ? text : [text]
      text.each do |ont_cls_id|
        acronym, cls_uri = ont_cls_id.split("\C-_")
        href = "#{$UI_URL}/ontologies/#{acronym}?p=classes&conceptid=#{CGI.escape(cls_uri)}"
        concept_links << "<a href='#{href}' class='ri_concept' data-ontology_id='#{acronym}' data-applied_label='false' data-concept_id='#{CGI::escape(cls_uri)}'>view class in #{$SITE}</a>"
      end
      return concept_links.join("<br/>")
    end
  end
end
