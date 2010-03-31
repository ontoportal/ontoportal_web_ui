module OntologiesHelper
 
  # Provides a link or string based on the status of an ontology.
  def get_visualize_link(ontology)
    # Don't display a link for ontologies that aren't browsable
    # (these are temporarily defined in environment.rb)
    unless $NOT_EXPLORABLE.nil?
      $NOT_EXPLORABLE.each do |virtual_id|
        if ontology.ontologyId.eql?(virtual_id.to_s)
          return ""
        end
      end
    end
    
    case ontology.statusId.to_i
    when 1 # Ontology is parsing
      return "Waiting to Parse"
    when 2
      return "Parsing Ontology"
    when 3 # Ontology is ready to be explored
      return "<a href=\"/visualize/#{ontology.id}\">Explore</a>"
    when 4 # Error in parsing
      return "Parsing Error"
    when 6 # Ontology is deprecated
      return "Archived, not available to explore"
    end
  end
  
  # Provides a link for an ontology based on where it's hosted (BioPortal or remote)
  def get_download_link(ontology)
    # Don't display a link for ontologies that aren't downloadable
    # (these are temporarily defined in environment.rb)
    unless $NOT_DOWNLOADABLE.nil?
      $NOT_DOWNLOADABLE.each do |virtual_id|
        if ontology.ontologyId.eql?(virtual_id.to_s)
          return ""
        end
      end
    end
    
    if ontology.isRemote.to_i.eql?(1)
      return "<a href=\"#{ontology.homepage}\" target=\"_blank\">Ontology Homepage</a>"
    else
      return "<a href=\"#{DataAccess.download(ontology.id)}\" target=\"_blank\">Download Ontology</a>"
    end
  end
  
  def get_view_ontology_version(view_on_ontology_id)
    return DataAccess.getOntology(view_on_ontology_id).versionNumber
  end
  
end