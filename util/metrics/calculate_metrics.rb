class CalculateMetrics
  
  require 'rubygems'
  require 'rest_client' 
  require 'rexml/document'
  require 'open-uri'
  require 'sqlite3'

  BASE_URL = "http://stagerest.bioontology.org/bioportal"
  #BASE_URL = "http://localhost:8080/bioportal"
  
  ONTOLOGIES_PATH = "/ontologies/active/"
  METRICS_PATH = "/ontologies/metrics/"
  PARSE_ONTOLOGY = "/ontologies/parse/%ONT%"
  APPLICATION_ID = "4ea81d74-8960-4525-810b-fa1baab576ff"
  
  STATUS_SUCCESS = 10
  STATUS_ERROR = 20
  STATUS_NOT_PARSED = 21
  
  COLUMN = { :ontologyid => 0, :status => 1, :display_label => 2, :message => 3}
  
  # How many ontologies do you want to process at once?
  BATCH_LOAD = 25
  
  def self.calculate_metrics
    processed_onts = {}
    
    RestClient.log = 'stdout'
    
    resource = RestClient::Resource.new BASE_URL + METRICS_PATH, :timeout => 34560
    
    ont_list = getOntologyList()
    
    # Create database in same directory as script
    script_path = File.dirname(__FILE__)
    status = SQLite3::Database.open("#{script_path}/metrics.db")

    create_tables(status)

    ont_list.each do |ontology|
      status.execute("update ont_status set format = ? where ontologyid = ?", ontology.format, ontology.id)
    end
    
    status.execute("select * from ont_status") do |row|
      processed_onts[row[COLUMN[:ontologyid]]] = row[COLUMN[:display_label]]
    end
    
    load_count = 0
    ont_list.each do |ontology|
      if processed_onts.has_key?(ontology.id.to_s)
        puts "Skipping #{ontology.id}, #{ontology.displayLabel} (already processed)"
        next
      end
      
      if ontology.statusId.to_i != 3
        puts "Skipping #{ontology.id} (not valid / not parsed)"
        # We still want to add this so it doesn't get processed
        status.execute("insert into ont_status values (?, ?, ?, ?, ?)",
          ontology.id, STATUS_NOT_PARSED, ontology.displayLabel, "<ontologyid>#{ontology.id}</ontologyid>\n<error>Ontology is invalid or not parsed properly</error>", ontology.format)
        next
      end

      # Don't process more than the batch limit
      if load_count >= BATCH_LOAD
        return
      end
      load_count += 1
      
      begin
        response = resource.post :ontologyversionids => ontology.id, :applicationid => APPLICATION_ID
      rescue RestClient::RequestTimeout=>to
       	puts to.message
        status.execute("insert into ont_status values (?, ?, ?, ?, ?)",
       	  ontology.id, STATUS_ERROR, ontology.displayLabel, "<ontologyid>#{ontology.id}</ontologyid>\n#<error>{to.message}</error>", ontology.format)
       	next
      rescue Exception=>e
        load_count -= 1
        puts "Error with #{ontology.id}:"
        puts "#{e.response.body}" if defined? e.response.body
        status.execute("insert into ont_status values (?, ?, ?, ?, ?)",
          ontology.id, STATUS_ERROR, ontology.displayLabel, "<ontologyid>#{ontology.id}</ontologyid>\n#{e.response.body}", ontology.format)
        next
      end
      
      status.execute("insert into ont_status values (?, ?, ?, ?, ?)",
        ontology.id, STATUS_SUCCESS, ontology.displayLabel, "<ontologyid>#{ontology.id}</ontologyid>\n<success>Successfully calculated metrics</success>", ontology.format)
    end
    
  end
  
  def self.create_tables(db)
    begin
      sql = <<-SQL
        CREATE TABLE "ont_status" (
          "ontologyid" INTEGER PRIMARY KEY DEFAULT NULL,
          "status" INTEGER DEFAULT NULL,
          "display_label" TEXT DEFAULT NULL,
          "status_message" TEXT DEFAULT NULL,
          "format" TEXT DEFAULT NULL);
          SQL
      db.execute(sql)
    rescue SQLite3::SQLException=>sqle
    end

    begin
      sql = <<-SQL
        CREATE TABLE "status_codes" (
          "status" INTEGER,
          "status_meaning" TEXT);
      SQL
      db.execute(sql)
    rescue SQLite3::SQLException=>sqle
    end

    begin
      db.execute("insert into status_codes values (?, ?)", STATUS_SUCCESS, "SUCCESS")
      db.execute("insert into status_codes values (?, ?)", STATUS_ERROR, "ERROR")
      db.execute("insert into status_codes values (?, ?)", STATUS_NOT_PARSED, "NOT PARSED")
    rescue SQLite3::SQLException=>sqle
    end
  end
  
  def self.getOntologyList()
    ontologies=nil
    
    doc = REXML::Document.new(open(BASE_URL + ONTOLOGIES_PATH + "?applicationid=#{APPLICATION_ID}"))
    
    ontologies = errorCheck(doc)
    
    unless ontologies.nil?
      return ontologies
    end
    
    ontologies = []
    time = Time.now
    doc.elements.each("*/data/list/ontologyBean"){ |element| 
      ontologies << parseOntology(element)
    }
    puts "Ontology list parsed (#{Time.now - time})"
    return ontologies
  end
  
  def self.parseOntology(ontologybeanXML)
    
    ontology = OntologyWrapper.new
    ontology.id = ontologybeanXML.elements["id"].get_text.value.strip
    ontology.displayLabel= ontologybeanXML.elements["displayLabel"].get_text.value.strip rescue "No Label"
    ontology.ontologyId = ontologybeanXML.elements["ontologyId"].get_text.value.strip
    ontology.userId = ontologybeanXML.elements["userId"].get_text.value.strip rescue ""
    ontology.parentId = ontologybeanXML.elements["parentId"].get_text.value.strip rescue ""
    ontology.format = ontologybeanXML.elements["format"].get_text.value.strip rescue  ""
    ontology.versionNumber = ontologybeanXML.elements["versionNumber"].get_text.value.strip rescue ""
    ontology.internalVersion = ontologybeanXML.elements["internalVersionNumber"].get_text.value.strip
    ontology.versionStatus = ontologybeanXML.elements["versionStatus"].get_text.value.strip rescue ""
    ontology.isCurrent = ontologybeanXML.elements["isCurrent"].get_text.value.strip rescue ""
    ontology.isRemote = ontologybeanXML.elements["isRemote"].get_text.value.strip rescue ""
    ontology.isReviewed = ontologybeanXML.elements["isReviewed"].get_text.value.strip rescue ""
    ontology.statusId = ontologybeanXML.elements["statusId"].get_text.value.strip rescue ""
    ontology.dateReleased =  Date.parse(ontologybeanXML.elements["dateReleased"].get_text.value).strftime('%m/%d/%Y') rescue ""
    ontology.contactName = ontologybeanXML.elements["contactName"].get_text.value.strip rescue ""
    ontology.contactEmail = ontologybeanXML.elements["contactEmail"].get_text.value.strip rescue ""
    ontology.urn = ontologybeanXML.elements["urn"].get_text.value.strip rescue ""
    ontology.isFoundry = ontologybeanXML.elements["isFoundry"].get_text.value.strip rescue ""
    ontology.isManual = ontologybeanXML.elements["isManual"].get_text.value.strip rescue ""
    ontology.filePath = ontologybeanXML.elements["filePath"].get_text.value.strip rescue ""
    ontology.homepage = ontologybeanXML.elements["homepage"].get_text.value.strip rescue ""
    ontology.documentation = ontologybeanXML.elements["documentation"].get_text.value.strip rescue ""
    ontology.publication = ontologybeanXML.elements["publication"].get_text.value.strip rescue ""
    ontology.dateCreated = Date.parse(ontologybeanXML.elements["dateCreated"].get_text.value).strftime('%m/%d/%Y') rescue ""
    ontology.preferredNameSlot=ontologybeanXML.elements["preferredNameSlot"].get_text.value.strip rescue ""
    ontology.synonymSlot=ontologybeanXML.elements["synonymSlot"].get_text.value.strip rescue ""
    ontology.description=ontologybeanXML.elements["description"].get_text.value.strip rescue ""
    ontology.abbreviation=ontologybeanXML.elements["abbreviation"].get_text.value.strip rescue ""    
    ontology.categories = []
    
    ontologybeanXML.elements["categoryIds"].elements.each{|element|
      ontology.categories<< element.get_text.value.strip
    }
    
    # View stuff
    ontology.isView = ontologybeanXML.elements["isView"].get_text.value.strip rescue "" 
    ontology.viewOnOntologyVersionId = ontologybeanXML.elements['viewOnOntologyVersionId'].elements['int'].get_text.value rescue "" 
    ontology.viewDefinition = ontologybeanXML.elements["viewDefinition"].get_text.value.strip rescue "" 
    ontology.viewGenerationEngine = ontologybeanXML.elements["viewGenerationEngine"].get_text.value.strip rescue "" 
    ontology.viewDefinitionLanguage = ontologybeanXML.elements["viewDefinitionLanguage"].get_text.value.strip rescue "" 
    
    ontology.view_ids = []
    ontology.virtual_view_ids=[]
    begin
      ontologybeanXML.elements["hasViews"].elements.each{|element|
        ontology.view_ids<< element.get_text.value.strip
      }
      ontologybeanXML.elements['virtualViewIds'].elements.each{|element|
        ontology.virtual_view_ids<< element.get_text.value.strip
      }
    rescue
    end
    
    return ontology
  end
  
  def self.errorCheck(doc)
    response=nil
    errorHolder={}
    begin
      doc.elements.each("org.ncbo.stanford.bean.response.ErrorStatusBean"){ |element|  
        
        errorHolder[:error]=true
        errorHolder[:shortMessage]= element.elements["shortMessage"].get_text.value.strip
        errorHolder[:longMessage]=element.elements["longMessage"].get_text.value.strip
        response=errorHolder
      }
    rescue
    end
    
    return response
  end
  
  class OntologyWrapper 
    
    attr_accessor :displayLabel
    attr_accessor :id
    attr_accessor :ontologyId
    attr_accessor :userId
    attr_accessor :parentId
    attr_accessor :format
    attr_accessor :versionNumber
    attr_accessor :internalVersion
    attr_accessor :versionStatus
    attr_accessor :isCurrent
    attr_accessor :isRemote
    attr_accessor :isReviewed
    attr_accessor :statusId
    attr_accessor :dateReleased
    attr_accessor :contactName
    attr_accessor :contactEmail
    attr_accessor :isFoundry
    attr_accessor :isManual
    attr_accessor :filePath
    attr_accessor :urn
    attr_accessor :homepage
    attr_accessor :documentation
    attr_accessor :publication
    attr_accessor :dateCreated
    
    attr_accessor :description
    attr_accessor :abbreviation
    attr_accessor :categories
    
    attr_accessor :synonymSlot
    attr_accessor :preferredNameSlot
    
    
    attr_accessor :reviews
    attr_accessor :projects
    attr_accessor :versions
    
    attr_accessor :view_ids
    attr_accessor :virtual_view_ids
    attr_accessor :view_beans
    attr_accessor :isView
    attr_accessor :viewDefinition
    attr_accessor :viewGenerationEngine
    attr_accessor :viewDefinitionLanguage
    attr_accessor :viewOnOntologyVersionId
    
    
    FILTERS={
      "All"=>0,
      "OBO Foundry"=>1,
      "UMLS"=>2,
      "WHO" =>3,
      "HL7"=>4
      
    }
    
    STATUS={
      "Waiting For Parsing"=>1,
      "Parsing"=>2,
      "Ready"=>3,
      "Error"=>4,
      "Not Applicable"=>5
    }
    
    FORMAT=["OBO","OWL-DL","OWL-FULL","OWL-LITE","PROTEGE","LEXGRID-XML","RRF"]
  end
  
  calculate_metrics
  
end