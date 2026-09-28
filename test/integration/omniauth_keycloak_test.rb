# frozen_string_literal: true

require 'test_helper'

class OmniauthKeycloakTest < ActionDispatch::IntegrationTest
  test 'omniauth providers env configuration populates keycloak provider' do
    ENV['KEYCLOAK_SITE'] = 'https://auth.example.org'
    ENV['KEYCLOAK_REALM'] = 'matportal'
    ENV['KEYCLOAK_CLIENT_ID'] = 'matportal-ui'
    ENV['KEYCLOAK_CLIENT_SECRET'] = 'secret123'
    ENV['KEYCLOAK_LABEL'] = 'Sign in with MatPortal Keycloak'
    ENV['KEYCLOAK_ENABLED'] = 'true'

    # Ensure frozen base config does not cause FrozenError
    $OMNIAUTH_PROVIDERS = {}.freeze

    load Rails.root.join('config/initializers/omniauth_providers_env.rb')

    assert $OMNIAUTH_PROVIDERS.key?(:keycloak)

    cfg = $OMNIAUTH_PROVIDERS[:keycloak]
    assert_equal :keycloak_openid, cfg[:strategy]
    assert_equal 'matportal-ui', cfg[:client_id]
    assert_equal 'secret123', cfg[:client_secret]
    assert_equal 'https://auth.example.org', cfg[:client_options][:site]
    assert_equal 'matportal', cfg[:client_options][:realm]
    assert_equal true, cfg[:enable]
    assert_equal 'Sign in with MatPortal Keycloak', cfg[:label]
  ensure
    ENV.delete('KEYCLOAK_SITE')
    ENV.delete('KEYCLOAK_REALM')
    ENV.delete('KEYCLOAK_CLIENT_ID')
    ENV.delete('KEYCLOAK_CLIENT_SECRET')
    ENV.delete('KEYCLOAK_LABEL')
    ENV.delete('KEYCLOAK_ENABLED')
  end

  test 'create_omniauth authentication failure sets flash error and renders index' do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:keycloak] = OmniAuth::AuthHash.new(
      provider: 'keycloak',
      uid: 'kc-123',
      credentials: { token: 'mock-token' },
      info: { email: 'test@example.org', name: 'Test User' }
    )

    rest_url = LinkedData::Client.settings.rest_url
    WebMock.stub_request(:post, %r{#{Regexp.escape(rest_url)}/users/authenticate}).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: '{"errors": ["Invalid token"]}'
    )

    get '/auth/keycloak/callback', env: {
      'omniauth.auth' => OmniAuth.config.mock_auth[:keycloak]
    }
    assert_response :success
    assert_select '.alert-message, .alert-container', /keycloak authentication failed/i
  ensure
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:keycloak)
  end
end
