class SyndicationController < ApplicationController

  def rss
    events = EventItem.find(:all,:order=>"created_at desc",:limit=>20)
    
    feed_items=[]
    
    for event in events
      case event.event_type
        when "Ontology"
          ontology = DataAccess.getOntology(event.event_type_id)
          feed_items << {:title=>"Ontology added",:description=>"Ontology  #{ontology.displayLabel} version #{ontology.versionNumber} was added to the repository",:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{ontology.id}"}
        when "Note"
          note = MarginNote.find(event.event_type_id)
          feed_items << {:title=>"Note added to #{note.concept.name} in #{note.ontology.displayLabel}",:description=>note.comment,:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{note.ontology.id}/#{note.concept_id}"}
        when "Mapping"
          mapping = Mapping.find(event.event_type_id)
          feed_items << {:title=>"Mapping added in #{mapping.ontology.displayLabel}",:description=>"Mapping from #{mapping.source_name} to #{mapping.dest_name}",:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{mapping.source_ont_id}/#{mapping.source_id}"}
      end
    end
    
    xml_feed = '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
      <channel>
      <title>Bioportal Updates</title>
      <link>http://stage.bioontology.org/syndication/rss</link>
      <description>Updates to the NCBO Bioportal Repository</description>
      <language>en-us</language>
      
      
      '
    
    for item in feed_items
      xml_feed <<"<item>"
      xml_feed <<"<title>#{item[:title]}</title"
      xml_feed <<"<link>#{item[:link]}</link>"
      xml_feed <<"<description>#{item[:description]}</description>"
      xml_feed <<"<dc:creator>Bioontology.org</dc:creator>"
      xml_feed <<"<dc:date>#{item[:date]}</dc:date>"
      xml_feed <<"</item>"
    end
    
    xml_feed <<"</channel>"
    xml_feed <<"</rss>"
    
    render :text=>xml_feed
  end

end
