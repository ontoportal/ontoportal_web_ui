class OntologyWrapper 

  attr_accessor :name  
  attr_accessor :coreFormat
  attr_accessor :currentVersion
  attr_accessor :downloadPath
  attr_accessor :metadataPath
  attr_accessor :releaseDate
  attr_accessor :project_count
  attr_accessor :review_count
  
  FILTERS={
  "All"=>0,
  "OBO Foundry"=>1,
  "UMLS"=>2,
  "WHO" =>3,
  "HL7"=>4
  
  }
  
  def reviews
    if self.review_count.nil?
      self.review_count = Review.count(:conditions=>{:ontology=>self.name})
    end
    return self.review_count
  end
  
  def projects
    if self.project_count.nil?
      self.project_count = Project.count(:conditions=>"uses.ontology = '#{self.name}'",:include=>:uses)
    end
    return self.project_count
  end
 
  def to_param    
     "#{name.gsub(" ","_").gsub("/","")}"
  end
  
  def initialize(ontology = nil)
    unless ontology.nil?
      self.name = ontology.displayLabel
      self.coreFormat = ontology.coreFormat
      self.currentVersion = ontology.currentVersion
      self.releaseDate = ontology.releaseDate
    end
  end
  
  def topLevelNodes
       DataAccess.getTopLevelNodes(self.name)     
  end
end