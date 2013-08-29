require 'cgi'
require 'ostruct'
require 'json'
require 'open-uri'

class BPIDResolver

  def self.retrieve_old_ids
    Thread.new do
      $ID_MAPPER = {}
      start = Time.now
      onts_views = RestHelper.ontologies + RestHelper.views
      onts_views.each do |o|
        $ID_MAPPER[o.ontologyId.to_i] = o.abbreviation
        RestHelper.ontology_versions(o.ontologyId).each do |v|
          $ID_MAPPER[v.id.to_i] = o.abbreviation
        end
      end
      puts "Finished getting old ids in #{Time.now - start}s"
    end
  end

  def self.id_to_acronym(id)
    $ID_MAPPER[id.to_i]
  end

end

class BPIDResolver::RestHelper
  CACHE = {}
  REST_URL = $REST_URL
  API_KEY = $API_KEY

  def self.get_json(path)
    if CACHE[path]
      json = CACHE[path]
    else
      apikey = path.include?("?") ? "&apikey=#{API_KEY}" : "?apikey=#{API_KEY}"
      begin
        json = open("#{REST_URL}#{path}#{apikey}", { "Accept" => "application/json" }).read
      rescue OpenURI::HTTPError => http_error
        raise http_error
      end
      json = JSON.parse(json, :symbolize_names => true)
      CACHE[path] = json
    end
    json
  end

  def self.get_json_as_object(json)
    if json.kind_of?(Array)
      return json.map {|e| OpenStruct.new(e)}
    elsif json.kind_of?(Hash)
      return OpenStruct.new(json)
    end
    json
  end

  def self.user(user_id)
    json = get_json("/users/#{user_id}")
    get_json_as_object(json[:success][:data][0][:userBean])
  end

  def self.ontologies
    get_json_as_object(get_json("/ontologies")[:success][:data][0][:list][0][:ontologyBean])
  end

  def self.views
    get_json_as_object(get_json("/views")[:success][:data][0][:list][0][:ontologyBean])
  end

  def self.ontology(version_id)
    get_json_as_object(get_json("/ontologies/#{version_id}")[:success][:data][0][:list][0][:ontologyBean])
  end

  def self.ontology_versions(virtual_id)
    get_json_as_object(get_json("/ontologies/versions/#{virtual_id}")[:success][:data][0][:list][0][:ontologyBean])
  end
end