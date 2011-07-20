class OntologyWrapper

  attr_accessor :displayLabel
  attr_accessor :id
  attr_accessor :ontologyId
  attr_accessor :userId
  attr_accessor :parentId
  attr_accessor :format
  attr_accessor :versionNumber
  attr_accessor :versionStatus
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
  attr_accessor :downloadLocation
  attr_accessor :isMetadataOnly
  
  attr_accessor :description
  attr_accessor :abbreviation
  attr_accessor :categories
  attr_accessor :groups
  
  attr_accessor :synonymSlot
  attr_accessor :preferredNameSlot
  attr_accessor :documentationSlot
  attr_accessor :authorSlot

  # RRF-specific metadata
  attr_accessor :targetTerminologies
  
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
  
  attr_accessor :codingScheme
  attr_accessor :categoryIds
  attr_accessor :groupIds
  
  
  
  FILTERS = {
    "All"=>0,
    "OBO Foundry"=>1,
    "UMLS"=>2,
    "WHO" =>3,
    "HL7"=>4
  }
  
  STATUS = {
    "Waiting For Parsing"=>1,
    "Parsing"=>2,
    "Ready"=>3,
    "Error"=>4,
    "Not Applicable"=>5
  }
  
  FORMAT = ["OBO","OWL-DL","OWL-FULL","OWL-LITE","PROTEGE","LEXGRID-XML","RRF","LOINC","RXNORM","UMLS-RELA"]
  
  LEXGRID_FORMAT = ["OBO","LEXGRID-XML","RRF","LOINC","RXNORM","UMLS-RELA"]
  
  PROTEGE_FORMAT = ["OWL","OWL-DL","OWL-FULL","OWL-LITE","PROTEGE"]
    
  def initialize(hash = nil, params = nil)
    if hash.nil?
      return
    end
    
    self.displayLabel             = hash['displayLabel']
    self.id                       = hash['id']
    self.ontologyId               = hash['ontologyId']
    self.userId                   = hash['userId']
    self.parentId                 = hash['parentId']
    self.format                   = hash['format']
    self.versionNumber            = hash['versionNumber']
    self.versionStatus            = hash['versionStatus']
    self.internalVersion          = hash['internalVersion']
    self.versionStatus            = hash['versionStatus']
    self.isCurrent                = hash['isCurrent']
    self.isRemote                 = hash['isRemote']
    self.isReviewed               = hash['isReviewed']
    self.statusId                 = hash['statusId']
    self.dateReleased             = hash['dateReleased']
    self.contactName              = hash['contactName']
    self.contactEmail             = hash['contactEmail']
    self.isFoundry                = hash['isFoundry']
    self.isManual                 = hash['isManual']
    self.filePath                 = hash['filePath']
    self.urn                      = hash['urn']
    self.homepage                 = hash['homepage']
    self.documentation            = hash['documentation']
    self.publication              = hash['publication']
    self.dateCreated              = hash['dateCreated']
    self.downloadLocation         = hash['downloadLocation']
    self.isMetadataOnly           = hash['isMetadataOnly']
    self.description              = hash['description']
    self.abbreviation             = hash['abbreviation']
    self.categories               = hash['categoryIds']
    self.groups                   = hash['groupIds']
    self.synonymSlot              = hash['synonymSlot']
    self.preferredNameSlot        = hash['preferredNameSlot']
    self.documentationSlot        = hash['documentationSlot']
    self.authorSlot               = hash['authorSlot']
    self.targetTerminologies      = hash['targetTerminologies']
    self.reviews                  = hash['reviews']
    self.projects                 = hash['projects']
    self.versions                 = hash['versions']
    self.view_ids                 = hash['hasViews']
    self.virtual_view_ids         = hash['virtualViewIds']
    self.isView                   = hash['isView']
    self.viewDefinition           = hash['viewDefinition']
    self.viewGenerationEngine     = hash['viewGenerationEngine']
    self.viewDefinitionLanguage   = hash['viewDefinitionLanguage']
    self.viewOnOntologyVersionId  = hash['viewOnOntologyVersionId']
    self.codingScheme             = hash['codingScheme']
  end    

  def views
    return DataAccess.getViews(self.ontologyId)
  end
  
  def from_params(params)
    self.displayLabel = params[:displayLabel]   
    self.id= params[:id]   
    self.ontologyId= params[:ontologyId]   
    self.userId= params[:userId]   
    self.parentId= params[:parentId]   
    self.format= params[:format]   
    self.versionNumber= params[:versionNumber]   
    self.internalVersion= params[:internalVersion]   
    self.versionStatus= params[:versionStatus]   
    self.isCurrent= params[:isCurrent]   
    self.isRemote= params[:isRemote]   
    self.isReviewed= params[:isReviewed]   
    self.statusId= params[:statusId]   
    self.dateReleased= params[:dateReleased]   
    self.contactName= params[:contactName]   
    self.contactEmail= params[:contactEmail]   
    self.isFoundry= params[:isFoundry]   
    self.filePath= params[:filePath]   
    self.urn= params[:urn]   
    self.homepage= params[:homepage]   
    self.documentation= params[:documentation]   
    self.publication= params[:publication]  
    self.isManual = params[:isManual]
    self.description= params[:description]
    self.categories = params[:categories]
    self.abbreviation = params[:abbreviation]
    self.synonymSlot = params[:synonymSlot]
    self.preferredNameSlot = params[:preferredNameSlot]    
    self.versionStatus = params[:versionStatus]
    
    # view items
    self.isView = params[:isView]
    self.viewOnOntologyVersionId = params[:viewOnOntologyVersionId]
    self.viewDefinition = params[:viewDefinition]
    self.viewDefinitionLanguage = params[:viewDefinitionLanguage]
    self.viewGenerationEngine = params[:viewGenerationEngine]
    
  end
  
  def map_count
    count = DataAccess.getMappingCountOntology(self.ontologyId) rescue 0
  end
  
  def getOntologyFromView
    return DataAccess.getOntology(self.viewOnOntologyVersionId)
  end
  
  
  def preload_ontology
     self.reviews = load_reviews
     self.projects = load_projects
  end
  
  def load_reviews
    if CACHE.get("#{self.ontologyId}::ReviewCount").nil?
      count = Review.count(:conditions=>{:ontology_id=>self.ontologyId})
      CACHE.set("#{self.ontologyId}::ReviewCount",count)
      return count
    else
      return CACHE.get("#{self.ontologyId}::ReviewCount")
    end
  end
  
  def load_projects
    if CACHE.get("#{self.ontologyId}::ProjectCount").nil?
      count = Project.count(:conditions=>"uses.ontology_id = '#{self.ontologyId}'",:include=>:uses)
      CACHE.set("#{self.ontologyId}::ProjectCount",count)
      return count
    else
      return CACHE.get("#{self.ontologyId}::ProjectCount")
    end
  end
 
  def to_param    
     "#{self.id}"
  end
  
  def topLevelNodes(view=false)
     DataAccess.getTopLevelNodes(self.id,view)     
  end
  
  def metrics
    return DataAccess.getOntologyMetrics(self.id)
  end
  
  # Queries for the latest version of this ontology and returns a comparison.
  def latest?
    latest = DataAccess.getLatestOntology(self.ontologyId)
    return latest.id.eql? self.id
  end
  
  # Generates a PURL address for this ontology
  def purl
    return "#{$PURL_PREFIX}/#{self.abbreviation}"
  end
  
  def owner_or_admin?(user)
    return !user.nil? && (user.admin? || user.id.to_i == self.userId.to_i)
  end
  
  def archived?
    return self.statusId.to_i == 6
  end
  
  # Check to see if ontology is stored remotely (IE metadata only)
  def metadata_only?
    return self.isMetadataOnly.eql?(1)
  end
  
  # Check criteria for browsable ontologies
  def terms_disabled?
    return self.metadata_only? || (!$NOT_EXPLORABLE.nil? && $NOT_EXPLORABLE.include?(self.ontologyId.to_i))
  end
  
  # Is this ontology just a huge bag of terms?
  def flat?
    return !$NOT_EXPLORABLE.nil? && $NOT_EXPLORABLE.include?(self.ontologyId.to_i)
  end
  
  def valid_tree_view?
    return self.statusId.to_i == 3 && !self.metadata_only?
  end
  
  def diffs
    DataAccess.getDiffs(self.ontologyId)
  end
  
  def versions_array
    DataAccess.getOntologyVersions(self.ontologyId).sort!{|x,y| y.internalVersion.to_i<=>x.internalVersion.to_i}
  end
  
  def is_in_search_index?
    begin
      result = DataAccess.searchQuery([self.ontologyId], "testingversionforontology")
      return result.ontology_hit_counts[self.ontologyId.to_i][:ontologyVersionId] == self.id.to_i
    rescue
      false
    end
  end
  
  def lexgrid?
    LEXGRID_FORMAT.include?(self.format.upcase)
  end
  
  def protege?
    PROTEGE_FORMAT.include?(self.format.upcase)
  end
  
  def format_handler
    return :lexgrid if self.lexgrid?
    return :protege if self.protege?
    return :unknown
  end

  def synonym_label
    DataAccess.getLightNode(self.id, self.synonymSlot).label rescue ""
  end  

  def preferred_name_label
    DataAccess.getLightNode(self.id, self.preferredNameSlot).label rescue ""
  end  

  def definition_label
    DataAccess.getLightNode(self.id, self.documentationSlot).label rescue ""
  end  

  def author_label
    DataAccess.getLightNode(self.id, self.authorSlot).label rescue ""
  end
  
  def to_params_hash
    hash = {}
    self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
    
    # Cleanup param names
    categories = hash['categories'].kind_of?(Array) ? hash['categories'].join(",") : hash['categories']
    groups = hash['groups'].kind_of?(Array) ? hash['groups'].join(",") : hash['groups']
    hash['categoryId'] = categories
    hash['groupId'] = groups
    hash.delete('categories')
    hash.delete('groups')
    
    hash
  end
  
  # Ontology Helper Methods
  def self.virtual_id?(ontology_id)
    return ontology_id.to_i < 2900
  end
  
  def self.version_id?(ontology_id)
    return ontology_id.to_i > 2900
  end

end
