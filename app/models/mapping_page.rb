class MappingPage < Array
  
  attr_accessor :page_number
  attr_accessor :page_size
  attr_accessor :size
  attr_accessor :total_mappings
  attr_accessor :mappings
  
  def initialize(hash = nil, params = nil)
    return if hash.nil? || hash.empty?
    
    self.mappings = []
    
    self.page_number = hash['pageNum'].to_i
    self.page_size = hash['pageSize'].to_i
    self.total_mappings = hash['numResultsTotal'].to_i
    self.size = hash['numResultsPage'].to_i
    
    hash['contents']['mappings'].each do |k,mapping|
      self.push(Mapping.new(mapping))
    end
  end
  
end
