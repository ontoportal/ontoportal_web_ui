class MappingLoader
  
  def self.processMappings(params)
    
   
     
    
    file=params[:file]
    source = params[:source]
    dest = params[:dest]
    name_lookup = params[:names]
    source_id_position=params[:source_position].to_i
    dest_id_position=params[:dest_position].to_i
    user_id = params[:user]
    if params[:comment].empty?
      comment_position= -1
    else
      comment_position = params[:comment]
    end
    map_source = params[:map_source]
    relationship_type= params[:relationship]
    if params[:delimiter].eql?("t")
      delimiter = "\t"
    else
      delimiter = params[:delimiter]
    end

    source_ontologies =[source]
    dest_ontologies = [dest]
    file.each do |record|
       items = record.split(delimiter)
       if items.size <1
         items = record.split(" ")
       end
       puts "#{items[source_id_position]} : #{items[dest_id_position]}" 


        mapping = Mapping.new



      if name_lookup  
        begin
          source_node = DataAccess.getNodeNameExactMatch(source_ontologies,items[source_id_position].chomp)[0]
        rescue Exception =>e
          puts e
          source_node = nil
        end

        if source_node.nil? 
          next
        end
        puts "Found  as source: #{source_node.id}"
        mapping.source_name = source_node.name
        mapping.source_id = source_node.id

        begin
          dest_node = DataAccess.getNodeNameExactMatch(dest_ontologies,items[dest_id_position].chomp)[0]
        rescue Exception => e
          puts e
          dest_node = nil
        end

        if dest_node.nil? 
          next
        end

        mapping.destination_name = dest_node.name
        mapping.destination_id = dest_node.id
        puts "Found  as Dest: #{dest_node.id}"
      else
        mapping.source_id = items[source_id_position].gsub("\"","").chomp
        mapping.destination_id = items[dest_id_position].gsub("\"","").chomp

        begin
         mapping.destination_name =DataAccess.getNode(dest,mapping.destination_id).name
        rescue Exception=>e
          puts e
        end
        begin
         mapping.source_name =DataAccess.getNode(source,mapping.source_id).name      
        rescue   Exception=>e
           puts e  
        end

      end
        mapping.map_type ="Automatic"
        mapping.source_ont = source
        mapping.destination_ont = dest
        mapping.created_at = Time.now
        mapping.user_id = user_id
        mapping.map_source = map_source
        mapping.relationship_type = relationship_type
        mapping.comment= items[comment_position] unless (comment_position < 1 || items[comment_position].nil?)
        mapping.save
    end
  
  end
  
  
  
end