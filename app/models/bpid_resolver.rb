require 'cgi'
require 'ostruct'
require 'json'
require 'open-uri'
require 'ncbo_resolver'

class BPIDResolver

  NCBO::Resolver.configure(redis_host: $REDIS_HOST, redis_port: $REDIS_PORT)
  RESOLVER = NCBO::Resolver

  def self.id_to_acronym(id)
    return if $REDIS_HOST && $REDIS_HOST.empty?
    acronym = RESOLVER::Ontologies.acronym_from_virtual_id(id)
    acronym = RESOLVER::Ontologies.acronym_from_version_id(id) unless acronym
    acronym
  end

  def self.acronym_to_virtual_id(acronym)
    return if $REDIS_HOST && $REDIS_HOST.empty?
    RESOLVER::Ontologies.virtual_id_from_acronym(acronym)
  end

  def self.uri_from_short_id(acronym, short_id)
    return if $REDIS_HOST && $REDIS_HOST.empty?
    RESOLVER::Classes.uri_from_short_id(acronym, short_id)
  end

end