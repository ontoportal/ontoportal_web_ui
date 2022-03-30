# frozen_string_literal: true

module MappingStatistics
  extend ActiveSupport::Concern

  MAPPING_STATISTICS_URL = "#{LinkedData::Client.settings.rest_url}/mappings/statistics/ontologies/"

  def mapping_counts(source_acronym)
    mapping_counts = []

    ontologies = LinkedData::Client::Models::Ontology.all(
      include: 'acronym,name,summaryOnly',
      display_links: false,
      display_context: false
    )

    statistics = LinkedData::Client::HTTP.get(MAPPING_STATISTICS_URL + source_acronym)
    statistics&.each_pair do |target_acronym, count|
      ont = ontologies.find { |o| o.acronym.eql? target_acronym.to_s }
      # Handle the case where statistics are still present for a deleted ontology
      next if ont.nil? || ont.summaryOnly

      mapping_counts << { target_ontology: ont, count: count }
    end

    mapping_counts.sort! { |a, b| a[:target_ontology].name.downcase <=> b[:target_ontology].name.downcase }
  end
end
