# ontologies_api_client init (default config works for the UI)
require 'ontologies_api_client'
LinkedData::Client.config do |config|
  config.cache       = $CLIENT_REQUEST_CACHING
  config.rest_url    = $REST_URL
  config.purl_prefix = $PURL_PREFIX
end
