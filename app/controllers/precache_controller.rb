require 'uri'
require 'ontology_wrapper'

class PrecacheController < ApplicationController

  $UI_PORT = "3000"

  def self.precache_all
    get_url("http://localhost:#{$UI_PORT}")
    get_url("http://localhost:#{$UI_PORT}/ontologies")
    get_url("http://localhost:#{$UI_PORT}/mappings")
    precache_ontology_summary
    precache_ontology_notes
    precache_ontology_mappings
  end
  
  def self.precache_ontology_summary
    ontologies = DataAccess.getOntologyList
    ontologies.each do |ont|
      get_url("http://localhost:#{$UI_PORT}/ontologies/#{ont.ontologyId}")
    end
  end
  
  def self.precache_ontology_notes
    ontologies = DataAccess.getOntologyList
    ontologies.each do |ont|
      get_url("http://localhost:#{$UI_PORT}/ontologies/#{ont.ontologyId}?p=mappings")
    end
  end
  
  def self.precache_ontology_mappings
    ontologies = DataAccess.getOntologyList
    ontologies.each do |ont|
      get_url("http://localhost:#{$UI_PORT}/ontologies/#{ont.ontologyId}?p=notes")
    end
  end
  
  def self.get_url(url)
    p url
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 360
  
    res = http.start { |http|
      path = uri.path.empty? ? "/" : uri.path
      http.get(path)
    }
    
    res.body
  end

end