class History
  attr_accessor :ontology_id,:ontology_name,:concept
  
  def initialize ontology_id,ontology_name, concept
    self.ontology_id = ontology_id
    self.ontology_name = ontology_name
    self.concept = concept
  end
end