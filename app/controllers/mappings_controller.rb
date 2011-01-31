require 'MappingLoader'
class MappingsController < ApplicationController
 

  # GET /mappings/new
  
  layout 'ontology'
  before_filter :authorize, :only=>[:create,:new]
  
  def index
    ontology_list = DataAccess.getOntologyList()
    views_list = DataAccess.getViewList()
    ontologies_mapping_count = DataAccess.getMappingCountOntologies

    ontologies_hash = {}
    ontology_list.each do |ontology|
      ontologies_hash[ontology.ontologyId] = ontology
    end
    
    views_list.each do |view|
      ontologies_hash[view.ontologyId] = view
    end

    @options = {}
    ontologies_mapping_count.each do |ontology|
      @options[ontologies_hash[ontology['ontologyId']].displayLabel + " (#{ontology['totalMappings']})"] = ontologies_hash[ontology['ontologyId']].id unless ontologies_hash[ontology['ontologyId']].nil?
    end
    
    @options = @options.sort
  end
  
  def service
    ontology = DataAccess.getLatestOntology(params[:ontology])
    
    if params[:id]
      concept = DataAccess.getNode(ontology.id,params[:id])    
      from =[]
      to = []
      from_res = ActiveRecord::Base.connection().execute("SELECT * from mappings  where source_ont =#{ontology.ontologyId} AND source_id = '#{concept.id}'")
      from_res.each_hash(with_table=false) {|x| from<<x}

      to_res = ActiveRecord::Base.connection().execute("SELECT * from mappings  where destination_ont =#{ontology.ontologyId} AND destination_id = '#{concept.id}'")
      to_res.each_hash(with_table=false) {|x| to<<x}

    else
      from=[]
      to=[]
      from_res = ActiveRecord::Base.connection().execute("SELECT * from mappings  where source_ont =#{ontology.ontologyId} ")
      to_res = ActiveRecord::Base.connection().execute("SELECT * from mappings  where destination_ont =#{ontology.ontologyId}")
      from_res.each_hash(with_table=false) {|x| from<<x}
      to_res.each_hash(with_table=false) {|x| to<<x}

    end
  
    #puts from.inspect
    #puts to.inspect
    mappings = {:mapping_from=>from,:mapping_to=>to}
    
    render :xml=> mappings
  end
  
  def ontology_service
    
  end
  
  
  def count
    ontology_list = DataAccess.getOntologyList()
    @ontology = DataAccess.getOntology(params[:ontology])
    ontologies_mapping_count = DataAccess.getMappingCountBetweenOntologies(@ontology.ontologyId)

    ontologies_hash = {}
    ontology_list.each do |ontology|
      ontologies_hash[ontology.ontologyId] = ontology
    end

    @ontology_id = @ontology.ontologyId
    @ontology_label = @ontology.displayLabel

    @source_counts = []
    ontologies_mapping_count.each do |ontology|
      if ontology['sourceMappings'].to_i > 0
        @source_counts << { 'count' => ontology['sourceMappings'], 'destination_ont' => ontology['ontologyId'], 'destination_ont_name' => ontologies_hash[ontology['ontologyId']].displayLabel, 'source_ont_name' => @ontology_label }
      end
    end

    @dest_counts = []
    ontologies_mapping_count.each do |ontology|
      if ontology['targetMappings'].to_i > 0
        @dest_counts << { 'count' => ontology['targetMappings'], 'source_ont' => ontology['ontologyId'], 'destination_ont_name' => @ontology_label, 'source_ont_name' => ontologies_hash[ontology['ontologyId']].displayLabel }
      end
    end

    render :partial =>'count'
  end
  
  def show
    @ontology = DataAccess.getLatestOntology(params[:id])
    @target_ontology = DataAccess.getLatestOntology(params[:target])
    
    @mapping_pages = DataAccess.getBetweenOntologiesMappings(@ontology.ontologyId, @target_ontology.ontologyId, params[:page], 100, :user_id => params[:user], :sources => params[:map_source], :unidirectional => "true")
    
    @mappings = {}
    @map_sources = []
    @service_users = DataAccess.getUsers.sort{|x,y| x.username.downcase <=> y.username.downcase}
    @users = []
    user_count = DataAccess.getMappingCountOntologyUsers(@ontology.ontologyId)
    
    user_count.each do |x|
      for user in @service_users
        if x['userId'].to_i == user.id.to_i
          @users << user
        end
      end
    end
    
    
    for map in @mapping_pages
      @map_sources << map.map_source.gsub(/(<[^>]*>)/mi, "") unless map.map_source.nil? || map.map_source.empty?
      @map_sources.uniq!
      
      if @mappings[map.source_id].nil?
        @mappings[map.source_id] = [{:source_ont_name=>map.source_ont_name,:destination_ont_name=>map.destination_ont_name,:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.username],:count=>1}]
      else
        @mappings[map.source_id]
        
        found = false
        for mapping in @mappings[map.source_id]
          if mapping[:destination_id].eql?(map.destination_id)
            found = true
            mapping[:users] << map.user.username
            mapping[:users].uniq!
            mapping[:count] += 1
          end  
        end
        
        unless found
         @mappings[map.source_id]<< {:source_ont_name=>map.source_ont_name,:destination_ont_name=>map.destination_ont_name,:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.username],:count=>1}
        end
      end
    end
    
    @mappings = @mappings.sort {|a,b| b[1].length<=>a[1].length}

    # This converts the mappings into an object that can be used with the pagination plugin
    @page_results = WillPaginate::Collection.create(@mapping_pages.page_number, @mapping_pages.page_size, @mapping_pages.total_mappings) do |pager|
       pager.replace(@mapping_pages)
    end
    
    if params[:rdf].nil? || !params[:rdf].eql?("rdf")
      render :partial=>'show'
    else
      send_data to_RDF(@mapping_pages), :type => 'text/html', :disposition => 'attachment; filename=mappings.rdf'
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
    ontology = DataAccess.getOntology(params[:ontology])
    @mapping = Mapping.new
    @mapping.source_id = params[:source_id]
    @mapping.source_ont = ontology.ontologyId
    @mapping.source_version_id=ontology.id
    @ontologies = DataAccess.getActiveOntologies() #populates dropdown
    @name = params[:source_name] #used for display
    
    render :layout=>false
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    source = DataAccess.getNode(params[:mapping]['source_version_id'], params[:mapping]['source_id'])
    target = DataAccess.getNode(params[:mapping]['destination_version_id'], params[:mapping]['destination_id'])
    comment = params[:mapping]['comment']
    unidirectional = (params[:bidirectional].to_i == 0)
    
    @mapping = DataAccess.createMapping(source.fullId, source.ontology.ontologyId, target.fullId, target.ontology.ontologyId, session[:user].id, comment, unidirectional)
    
    #repopulates table
    @ontology = DataAccess.getOntology(source.ontology.id)
    @mappings = DataAccess.getConceptMappings(source.ontology.ontologyId, source.fullId)    

    
    # Adds mapping to syndication
    @mapping.each do |mapping|
      event = EventItem.new
      event.event_type= "Mapping"
      event.event_type_id = mapping.id
      event.ontology_id = mapping.source_ont
      event.save
    end
    
    render :partial => 'mapping_table'
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
             <mappings:source rdf:resource='#{$UI_URL}/#{to_param(mapping.source_ont)}/#{mapping.source_id}'/>
             <mappings:target rdf:resource='#{$UI_URL}/#{to_param(mapping.destination_ont)}/#{mapping.destination_id}'/>
         </mappings:One_to_one_mapping>
         <mappings:Mapping_Metadata rdf:ID=\"#{count+1}\">
             <mappings:author rdf:datatype=\"&xsd;string\">#{mapping.user.username}</mappings:author>
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
