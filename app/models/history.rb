class History
  attr_accessor :ontology,:concept
  
  def initialize ontology, concept
    self.ontology = ontology.name
    self.concept = concept.id
  end
end