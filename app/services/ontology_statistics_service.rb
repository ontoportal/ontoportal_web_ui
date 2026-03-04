# frozen_string_literal: true

class OntologyStatisticsService < ApplicationService
  def initialize(ont_acronyms)
    @ont_acronyms = ont_acronyms
    @metrics = ontology_metrics(@ont_acronyms)
  end

  def call
    {
      ontology_count: @ont_acronyms.size,
      class_count: @metrics[:classes],
      property_count: @metrics[:properties],
      individual_count: @metrics[:individuals]
    }
  end

  private

  def ontology_metrics(ont_acronyms)
    query_string = { include: 'classes,properties,individuals', display_links: false, display_context: false }
    metrics = LinkedData::Client::Models::Metrics.all(query_string)

    metrics.select! do |m|
      acronym = m.id.split('/ontologies/').last.split('/').first
      ont_acronyms.include?(acronym)
    end

    metrics.each_with_object({ classes: 0, properties: 0, individuals: 0 }) do |m, sums|
      sums[:classes] += m.classes
      sums[:properties] += m.properties
      sums[:individuals] += m.individuals
    end
  end
end
