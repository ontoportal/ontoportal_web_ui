class MappingPage < Array

  attr_accessor :page_number
  attr_accessor :page_size
  attr_accessor :size
  attr_accessor :total_mappings
  attr_accessor :mappings

  def initialize(hash = nil, params = nil)
    return if hash.nil? || hash.empty?

    hash = hash["page"] if hash["page"]

    self.mappings = []

    self.page_number = hash['pageNum'].to_i
    self.page_size = hash['pageSize'].to_i
    self.total_mappings = hash['numResultsTotal'].to_i
    self.size = hash['numResultsPage'].to_i

    hash['contents']['mappings'].each do |k,mapping|
      # Check for many to many mappings and convert to individual ones
      if mapping['target'].size > 1 || mapping['source'].size > 1
        sources = mapping['source'].values
        targets = mapping['target'].values

        sources.each do |source|
          targets.each do |target|
            mapping['source'] = source
            mapping['target'] = target
            self.push(Mapping.new(mapping))
          end
        end
      else
        mapping['source'] = mapping['source']['fullId']
        mapping['target'] = mapping['target']['fullId']
        self.push(Mapping.new(mapping))
      end
    end
  end

end
