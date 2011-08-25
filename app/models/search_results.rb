class SearchResults < Array
  attr_accessor :ontology_hit_counts
  attr_accessor :page_size
  attr_accessor :page_number
  attr_accessor :current_page_results
  attr_accessor :total_results
  attr_accessor :total_pages
  attr_accessor :results
  
  def initialize(hash = nil, params = nil)
    self.ontology_hit_counts = {}
    return if hash.nil?
    
    results = hash['contents']['searchResultList']
    
    self.results = results.nil? || results.length == 0 ? Array.new : results.values
    self.ontology_hit_counts = hash['contents']['ontologyHitList'].values
    self.page_size = hash['pageSize']
    self.total_results = hash['numResultsTotal']
    self.page_number = hash['pageNum']
    self.current_page_results = hash['numResultsPage']
    self.total_pages = hash['numPages']
  end
  
  def hash_for_serialization
    return {
      :ontology_hit_counts => self.ontology_hit_counts, :page_size => self.page_size,
      :page_number => self.page_number, :current_page_results => self.current_page_results,
      :total_results => self.total_results, :total_pages => self.total_pages,
      :results => self.results
    }
  end
  
end