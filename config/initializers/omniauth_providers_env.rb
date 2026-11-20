# frozen_string_literal: true

# Configure OmniAuth providers from environment variables when not set by config/bioportal_config_*.rb
$OMNIAUTH_PROVIDERS = ($OMNIAUTH_PROVIDERS || {}).dup

keycloak_site = ENV['KEYCLOAK_SITE']
keycloak_realm = ENV['KEYCLOAK_REALM']
keycloak_client_id = ENV['KEYCLOAK_CLIENT_ID']
keycloak_client_secret = ENV['KEYCLOAK_CLIENT_SECRET']

if [keycloak_site, keycloak_realm, keycloak_client_id, keycloak_client_secret].all? { |v| v && !v.strip.empty? }
  existing = $OMNIAUTH_PROVIDERS[:keycloak] || {}
  $OMNIAUTH_PROVIDERS[:keycloak] = existing.merge(
    strategy: existing[:strategy] || :keycloak_openid,
    name: existing[:name] || 'keycloak',
    icon: existing[:icon] || 'keycloak.svg',
    client_id: keycloak_client_id,
    client_secret: keycloak_client_secret,
    client_options: (existing[:client_options] || {}).merge(site: keycloak_site, realm: keycloak_realm),
    label: ENV['KEYCLOAK_LABEL'] || existing[:label] || 'Keycloak',
    enable: ENV.fetch('KEYCLOAK_ENABLED', 'true').to_s.downcase == 'true'
  )
end
