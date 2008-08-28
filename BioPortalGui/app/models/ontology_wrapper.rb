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
  
  attr_accessor :reviews
  attr_accessor :projects
  attr_accessor :versions
  
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
  
  FORMAT=["OBO","OWL-DL","OWL-FULL","OWL-LITE","PROTEGE","LEXGRID_XML"]
    
  
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
  end
  
  def map_count
    count = Mapping.find(:all,:conditions=>{:source_ont=>self.ontologyId}).size
  end
  
  
  def preload_ontology
     self.reviews = load_reviews
     self.projects = load_projects
  end
  
  def load_reviews

      if CACHE.get("#{self.ontologyId}::ReviewCount").nil?
            puts "calling Reviews No Cache"
          count = Review.count(:conditions=>{:ontology_id=>self.ontologyId})
          CACHE.set("#{self.ontologyId}::ReviewCount",count)
          return count
       else
             puts "calling Reviews Cache"
          return CACHE.get("#{self.ontologyId}::ReviewCount")
       end
  end
  
  def load_projects

    if CACHE.get("#{self.ontologyId}::ProjectCount").nil?
    puts "calling Projects No Cache"    
        count = Project.count(:conditions=>"uses.ontology_id = '#{self.ontologyId}'",:include=>:uses)
        CACHE.set("#{self.ontologyId}::ProjectCount",count)
        return count
     else
    puts "calling Projects Cache"    
        return CACHE.get("#{self.ontologyId}::ProjectCount")
     end
  end
 
  def to_param    
     "#{id}"
  end
  
  def topLevelNodes
       DataAccess.getTopLevelNodes(self.id)     
  end
end