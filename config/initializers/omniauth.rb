# Load env-based provider config before wiring OmniAuth.
require_relative 'omniauth_providers_env'

Rails.application.config.middleware.use OmniAuth::Builder do
  Array($OMNIAUTH_PROVIDERS).each do |provider_key, config|
    next unless config.is_a?(Hash)
    next if config[:enable] == false

    options = { client_options: {}.merge(config[:client_options].to_h) }
    options[:name] = config[:name] if config[:name]
    options[:pkce] = config[:pkce] unless config[:pkce].nil?
    options[:scope] = config[:scope] if config[:scope]

    provider config[:strategy] || provider_key, config[:client_id], config[:client_secret], options
  end
end
