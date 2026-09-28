# frozen_string_literal: true

# Configure OmniAuth providers from environment variables when not set by config/bioportal_config_*.rb
$OMNIAUTH_PROVIDERS = ($OMNIAUTH_PROVIDERS || {}).dup

keycloak_site = ENV['KEYCLOAK_SITE']
keycloak_realm = ENV['KEYCLOAK_REALM']
keycloak_client_id = ENV['KEYCLOAK_CLIENT_ID']
keycloak_client_secret = ENV['KEYCLOAK_CLIENT_SECRET']

if [keycloak_site, keycloak_realm, keycloak_client_id, keycloak_client_secret].all?(&:present?)
  $OMNIAUTH_PROVIDERS[:keycloak] = {
    strategy: :keycloak_openid,
    client_id: keycloak_client_id,
    client_secret: keycloak_client_secret,
    client_options: { site: keycloak_site, realm: keycloak_realm },
    label: ENV['KEYCLOAK_LABEL'] || 'Keycloak',
    enable: ENV.fetch('KEYCLOAK_ENABLED', 'true').to_s.downcase == 'true'
  }
end

