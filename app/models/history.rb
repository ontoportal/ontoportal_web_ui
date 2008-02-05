class History
  attr_accessor :ontology,:concept
  
  def initialize ontology, concept
    self.ontology = ontology
    self.concept = concept
  end
end