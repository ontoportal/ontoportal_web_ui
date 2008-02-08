class OntologyWrapper 

  attr_accessor :name  
  attr_accessor :coreFormat
  attr_accessor :currentVersion
  attr_accessor :downloadPath
  attr_accessor :metadataPath
  attr_accessor :releaseDate
  
  FILTERS={
  "All"=>0,
  "OBO Foundry"=>1,
  "UMLS"=>2,
  "WHO" =>3,
  "HL7"=>4
  
  }
   
  
 
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