# Load env-based provider config before wiring OmniAuth.
require_relative 'omniauth_providers_env'

Rails.application.config.middleware.use OmniAuth::Builder do
  Array($OMNIAUTH_PROVIDERS).each do |provider, config|
    next if config.is_a?(Hash) && config[:enable] == false

    provider config[:strategy] || provider, config[:client_id], config[:client_secret], client_options: {}.merge(config[:client_options].to_h)
  end
end

