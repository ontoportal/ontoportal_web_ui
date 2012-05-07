class OntologyRanker

  RANKED = Set.new([1422, 1353, 1032, 1352, 1000])
  WEIGHT = { 1422 => 2887, 1353 => 2733, 1032 => 1339, 1352 => 1040, 1000 => 920 }

  ##
  # Takes an array of integers, arrays, or hashes. If using array or hash, must provide location of ontology virtual id.
  # Options:
  # :position => location in the array (int) or hash key containing the virtual id
  def self.rank(ont_ary, options = {})
    return nil if !ont_ary.kind_of?(Array)
    position = options[:position]

    # We use an hash for the ranked ontologies to preserve the Lucene ordering
    ranked = {}
    not_ranked = []
    ont_ary.each do |ont|
      if position.nil?
        if RANKED.include?(ont.to_i)
          ranked[ont.to_i] = [] if ranked[ont.to_i].nil?
          ranked[ont_to_i] << ont
        else
          not_ranked << ont
        end
      else
        if RANKED.include?(ont[position].to_i)
          ranked[ont[position].to_i] = [] if ranked[ont[position].to_i].nil?
          ranked[ont[position].to_i] << ont
        else
          not_ranked << ont
        end
      end
    end

    if position.nil?
      ranked.sort! {|a,b| WEIGHT[b.to_i] <=> WEIGHT[a.to_i]}
    else
      # Get a ranked list of the virtual ids in the ranked set
      ranked_ids = ranked.keys.sort {|a,b| WEIGHT[b.to_i] <=> WEIGHT[a.to_i]}
      # Bsedon the ranking of ids, recombine the results
      new_ranked = []
      ranked_ids.each do |id|
        new_ranked.concat ranked[id]
      end
      ranked = new_ranked
    end

    ranked.concat not_ranked
  end

  def self.rank!(ont_ary, options = {})
    ont_ary = self.rank(ont_ary, options)
  end

end