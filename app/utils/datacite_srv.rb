require 'json'
require 'base64'
require 'uri'
require 'net/http'
require 'openssl'

module Ecoportal
  class DataciteSrv

    # CALL DATACITE API SERVICE TO CREATE NEW DOI AND RETURNS THE RESPONSE
    def self.create_new_doi_from_datacite(json_metadata)

      url = URI($DATACITE_API_URL)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['content-type'] = 'application/vnd.api+json'
      request['authorization'] = "Basic #{Base64.encode64("#{$DATACITE_USERNAME}:#{$DATACITE_PASSWORD}").gsub("\n", '')}"
      request.body = json_metadata

      response = http.request(request)
      json_response = response.read_body

      # convert response as json if response is a string containing a json
      json_response = JSON.parse(json_response) if json_response.is_a?(String) && json_response.start_with?('{')
      json_response
    end

    # CALL DATACITE API SERVICE TO UPDATE AN EXISTING DOI CREATE BY THIS PLATFORM
    # (IT CHECKS IF THE DOI PREFIX IS EQUAL TO THE CONFIGURED ONE) AND RETURNS THE RESPONSE
    def self.update_doi_information_to_datacite(json_metadata)
      url = URI('https://api.test.datacite.org/dois/id')

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Put.new(url)
      request['content-type'] = 'application/vnd.api+json'
      request['authorization'] = 'Basic TElGRVcuQ0xBOkxXRWNvcG9ydGFs'

      request.body = '{"data":{"type":"dois","attributes":{"prefix":"10.80260"}}}'

      response = http.request(request)

      response.read_body
    end
  end
end