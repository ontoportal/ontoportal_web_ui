class SearchResults < Array
  attr_accessor :ontology_hit_counts
  
  def initialize(*args)
    super(*args)
    self.ontology_hit_counts = {}
  end
  
end