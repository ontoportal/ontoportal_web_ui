class SyndicationController < ApplicationController


  


  def rss
    
    limit = params[:limit] || 20
    if params[:ontologies].nil?
      events = EventItem.find(:all,:order=>"created_at desc",:limit=>limit)
    else
      events = EventItem.find(:all,:conditions=>{:ontology_id=>params[:ontologies].split(",")},:order=>"created_at desc",:limit=>limit)
    end
    feed_items=[]
    
    for event in events
      begin
        case event.event_type
          when "Ontology"
            ontology = DataAccess.getOntology(event.event_type_id)
            feed_items << {:title=>"Ontology added",:description=>"Ontology  #{ontology.displayLabel} version #{ontology.versionNumber} was added to the repository",:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{ontology.id}"}
          when "Note"
            note = MarginNote.find(event.event_type_id)
            feed_items << {:title=>"Note added to #{note.concept.name} in #{note.ontology.displayLabel}",:description=>note.comment,:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{note.ontology.id}/#{note.concept_id}"}
          when "Mapping"
            mapping = Mapping.find(event.event_type_id)
            feed_items << {:title=>"Mapping added in #{mapping.ontology.displayLabel}",:description=>"Mapping from #{mapping.source_name} to #{mapping.destination_name}",:date=>event.created_at,:link=>"http://bioportal.bioontology.org/visualize/#{mapping.source_version_id}/#{mapping.source_id}"}
        end
      rescue
        #Catches exceptions from backend discrepencies
      end
    end
    
    if params[:callback].nil?
    
    
    xml_feed = '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
      <channel>
      <title>Bioportal Updates</title>
      <link>http://stage.bioontology.org/</link>
      <description>Updates to the NCBO Bioportal Repository</description>
      <language>en-us</language>
      
      
      '
    
    for item in feed_items
      xml_feed <<"<item>"
      xml_feed <<"<title>#{item[:title]}</title>"
      xml_feed <<"<link>#{item[:link]}</link>"
      xml_feed <<"<description>#{item[:description]}</description>"
      xml_feed <<"<dc:creator>Bioontology.org</dc:creator>"
      xml_feed <<"<dc:date>#{item[:date]}</dc:date>"
      xml_feed <<"</item>"
    end
    
    xml_feed <<"</channel>"
    xml_feed <<"</rss>"
    
    render :text=>xml_feed
    
    else
      json_response="#{params[:callback]}(["
      for item in feed_items
        json_response <<"{"
        json_response <<"title:'#{item[:title].split(" in ")[0]}',"
        json_response <<"link: '#{item[:link]}',"
        json_response <<"description:'#{item[:description]}',"
        json_response <<"date:'#{item[:date].strftime("%m/%d/%y")}'"
        json_response <<"}"
        unless item.eql?(feed_items.last)
          json_response<<","
        end
      end
      
      
      json_response << "])"
      
      render :text=>json_response
    end
    
  end

end
