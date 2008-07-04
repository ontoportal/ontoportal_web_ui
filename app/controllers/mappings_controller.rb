require 'MappingLoader'
class MappingsController < ApplicationController
 

  # GET /mappings/new
  
  layout 'search'
  
  def index
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
  end
  
  def count
    @source_counts =[]
    names = ActiveRecord::Base.connection().execute("SELECT count(*) as count,destination_ont from mappings  where source_ont like '#{params[:ontology]}' group by destination_ont")
     names.each_hash(with_table=false) {|x| @source_counts<<x}
    
    @dest_counts = []
    names = ActiveRecord::Base.connection().execute("SELECT count(*) as count,source_ont from mappings  where destination_ont like '#{params[:ontology]}' group by source_ont")
    names.each_hash(with_table=false) {|x| @dest_counts<<x} 
    
    render :partial =>'count'
  end
  
  def show
    #Select *, count(*) as count from mappings where source_ont = 'NCI Thesaurus' and destination_ont = 'Mouse adult gross anatomy' group by destination_id order by count desc limit 100 OFFSET 0 
    @ontology = params[:id]
    @destination_ont=params[:target]
    
    
    expanded_query = ""
    if !params[:user].nil? && !params[:user].empty?
      expanded_query << " AND user_id = #{params[:user]} "
    end
    if !params[:map_source].nil? && !params[:map_source].empty?
      expanded_query << " AND map_source like '%#{params[:map_source]}%'"
    end
    
    @mapping_pages = Mapping.paginate_by_sql("Select source_id, count(*) as count from mappings where source_ont = '#{params[:id]}' and destination_ont = '#{params[:target]}' #{expanded_query} group by source_id order by count desc",:page => params[:page], :per_page => 100,:include=>'users')
  if params[:rdf].nil?
    mapping_objects = Mapping.find(:all,:conditions=>["source_ont = '#{params[:id]}' AND destination_ont = '#{params[:target]}' AND source_id IN (?) #{expanded_query}",@mapping_pages.collect{|item| item[:source_id]}.flatten])
  else
    mapping_objects =  Mapping.find(:all,:conditions=>["source_ont = '#{params[:id]}' AND destination_ont = '#{params[:target]}'  #{expanded_query}"])
  end
#    @mapping_pages = Mapping.paginate(:page => params[:page], :per_page => 100 ,:conditions=>{:source_ont=>params[:id],:destination_ont=>params[:target]},:order=>'count()',:include=>:user)
    @mappings = {}
    @map_sources = []
    @users = User.find(:all)
    for map in mapping_objects
      puts map.source_id
      @map_sources << map.map_source.gsub(/<a.*?a>/mi, "")  unless map.map_source.nil?
      @map_sources.uniq!
      
      if @mappings[map.source_id].nil?
        puts "new mapping"
        @mappings[map.source_id] = [{:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.user_name],:count=>1}]
      else
        puts "Mapping exists"
        @mappings[map.source_id]
        found = false
        for mapping in @mappings[map.source_id]
          puts map.destination_id
          if mapping[:destination_id].eql?(map.destination_id)
            found = true
            mapping[:users]<<map.user.user_name
            mapping[:users].uniq!
            mapping[:count]+= 1
            puts "adding to count #{mapping[:count]}"
          end  
        end
        unless found
         @mappings[map.source_id]<< {:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.user_name],:count=>1}
        end
      end
    end
    @mappings = @mappings.sort {|a,b| b[1].length<=>a[1].length}   #=> [["c", 10], ["a", 20], ["b", 30]]

    if params[:rdf].nil?
      render :partial=>'show'
    else
      send_data to_RDF(mapping_objects), :type => 'text/html', :disposition => 'attachment; filename=mappings.rdf'
    end
  end
  
  def upload
    @ontologies = @ontologies = DataAccess.getOntologyList()
        @users = User.find(:all)
  end
  
  
  def process_mappings
    
    
    
      MappingLoader.processMappings(params)
    
     flash[:notice] = 'Mappings are processed'
     @ontologies = @ontologies = DataAccess.getOntologyList()
     @users = User.find(:all)
     render :action=>:upload
  end
  
  def new
    @mapping = Mapping.new
    @mapping.source_id = params[:source_id]
    @mapping.source_ont = undo_param(params[:ontology])
    @ontologies = DataAccess.getActiveOntologies() #populates dropdown
    @name = params[:source_name] #used for display
    
    render :layout=>false
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    #creates mapping
    @mapping = Mapping.new(params[:mapping])
    @mapping.user_id = session[:user].id
    @mapping.source_name=DataAccess.getNode(@mapping.source_ont,@mapping.source_id).name
    @mapping.destination_name=DataAccess.getNode(@mapping.destination_ont,@mapping.destination_id).name
    @mapping.save
    
    count = Mapping.count(:conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    CACHE.set("#{@mapping.source_ont.gsub(" ","_")}::#{@mapping.source_id}_MappingCount",count)
    
    
    #repopulates table
    @mappings =  Mapping.find(:all, :conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    @ontology = DataAccess.getOntology(@mapping.source_ont)
    render :partial =>'mapping_table'
     

  end

private

  def to_RDF(mappings)
    rdf_text = "<?xml version='1.0' encoding='UTF-8'?>


     <!DOCTYPE rdf:RDF [
         <!ENTITY xsd 'http://www.w3.org/2001/XMLSchema#' >
         <!ENTITY a 'http://protege.stanford.edu/system#' >
         <!ENTITY rdfs 'http://www.w3.org/2000/01/rdf-schema#' >
         <!ENTITY mappings 'http://protege.stanford.edu/mappings#' >
         <!ENTITY rdf 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' >
     ]>


     <rdf:RDF xmlns=\"http://bioontology.org/mappings/mappings.rdf#\"
          xml:base=\"http://bioontology.org/mappings/mappings.rdf\"
          xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
          xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
          xmlns:mappings=\"http://protege.stanford.edu/mappings#\"
          xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
         <rdf:Property rdf:about=\"&mappings;author\">
             <rdfs:domain rdf:resource=\"&mappings;Mapping_Metadata\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
             <rdfs:label rdf:datatype=\"&xsd;string\">author</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;comment\">
             <rdfs:domain rdf:resource=\"&mappings;Mapping_Metadata\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
              <rdfs:label rdf:datatype=\"&xsd;string\">comment</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;confidence\">
             <rdfs:domain rdf:resource=\"&mappings;Mapping_Metadata\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
             <rdfs:label rdf:datatype=\"&xsd;string\">confidence</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;date\">
             <rdfs:domain rdf:resource=\"&mappings;Mapping_Metadata\"/>
             <rdfs:range rdf:resource=\"&xsd;date\"/>
             <rdfs:label rdf:datatype=\"&xsd;string\">date</rdfs:label>
         </rdf:Property>
         <rdfs:Class rdf:about=\"&mappings;Mapping_Metadata\">
             <rdfs:label rdf:datatype=\"&xsd;string\"
                 >Mapping_Metadata</rdfs:label>
         </rdfs:Class>
         <rdf:Property rdf:about=\"&mappings;mapping_metadata\">
             <rdfs:domain rdf:resource=\"&mappings;One_to_one_mapping\"/>
             <rdfs:range rdf:resource=\"&mappings;Mapping_Metadata\"/>
              <rdfs:label rdf:datatype=\"&xsd;string\"
                 >mapping_metadata</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;mapping_source\">
             <rdfs:domain rdf:resource=\"&mappings;Mapping_Metadata\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
              <rdfs:label rdf:datatype=\"&xsd;string\">authority</rdfs:label>
         </rdf:Property>
         <rdfs:Class rdf:about=\"&mappings;One_to_one_mapping\">
             <rdfs:label rdf:datatype=\"&xsd;string\"
                 >One_to_one_mapping</rdfs:label>
         </rdfs:Class>
         <rdf:Property rdf:about=\"&mappings;relation\">
             <rdfs:domain rdf:resource=\"&mappings;One_to_one_mapping\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
              <rdfs:label rdf:datatype=\"&xsd;string\">relation</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;source\">
             <rdfs:domain rdf:resource=\"&mappings;One_to_one_mapping\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
             <rdfs:label rdf:datatype=\"&xsd;string\">source</rdfs:label>
         </rdf:Property>
         <rdf:Property rdf:about=\"&mappings;target\">
             <rdfs:domain rdf:resource=\"&mappings;One_to_one_mapping\"/>
             <rdfs:range rdf:resource=\"&xsd;string\"/>
             <rdfs:label rdf:datatype=\"&xsd;string\">target</rdfs:label>
         </rdf:Property>"
         
         count = 1
         
         for mapping in mappings
          rdf_text << "<mappings:One_to_one_mapping rdf:ID=\"#{count}\">
             <mappings:mapping_metadata rdf:resource=\"##{count+1}\"/>
             <mappings:relation rdf:datatype=\"&xsd;string\">#{mapping.relationship_type}</mappings:relation>
             <mappings:source rdf:resource='http://alpha.bioontology.org/#{to_param(mapping.source_ont)}/#{mapping.source_id}'/>
             <mappings:target rdf:resource='http://alpha.bioontology.org/#{to_param(mapping.destination_ont)}/#{mapping.destination_id}'/>
         </mappings:One_to_one_mapping>
         <mappings:Mapping_Metadata rdf:ID=\"#{count+1}\">
             <mappings:author rdf:datatype=\"&xsd;string\">#{mapping.user.user_name}</mappings:author>
             <mappings:mapping_source rdf:datatype=\"&xsd;string\">#{mapping.map_source}</mappings:mapping_source>
             <mappings:comment rdf:datatype=\"&xsd;string\">#{mapping.comment}</mappings:comment>
             <mappings:date rdf:datatype=\"&xsd;date\">#{mapping.created_at}</mappings:date>
         </mappings:Mapping_Metadata>"
         
         count +=2
         
        end
         
         
     rdf_text << "</rdf:RDF>"
     return rdf_text
  end


end
