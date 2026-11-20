# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class OmniauthKeycloakTest < ActionDispatch::IntegrationTest
  KEYCLOAK_ENV_KEYS = %w[
    KEYCLOAK_SITE
    KEYCLOAK_REALM
    KEYCLOAK_CLIENT_ID
    KEYCLOAK_CLIENT_SECRET
    KEYCLOAK_LABEL
    KEYCLOAK_ENABLED
  ].freeze

  def setup
    super
    @original_omniauth_providers = $OMNIAUTH_PROVIDERS
    @original_env = KEYCLOAK_ENV_KEYS.each_with_object({}) do |key, env|
      env[key] = ENV[key]
      ENV.delete(key)
    end
    @original_test_mode = OmniAuth.config.test_mode
    @original_mock_auth = OmniAuth.config.mock_auth.dup
  end

  def teardown
    $OMNIAUTH_PROVIDERS = @original_omniauth_providers
  ensure
    @original_env&.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
    OmniAuth.config.test_mode = @original_test_mode
    OmniAuth.config.mock_auth.replace(@original_mock_auth) if @original_mock_auth
    super
  end

  test 'omniauth providers env populates keycloak provider with default name, icon, and enabled state' do
    ENV['KEYCLOAK_SITE'] = 'https://auth.example.org'
    ENV['KEYCLOAK_REALM'] = 'matportal'
    ENV['KEYCLOAK_CLIENT_ID'] = 'matportal-ui'
    ENV['KEYCLOAK_CLIENT_SECRET'] = 'secret123'
    ENV['KEYCLOAK_LABEL'] = 'Sign in with MatPortal Keycloak'
    ENV.delete('KEYCLOAK_ENABLED')

    # Ensure frozen base config does not cause FrozenError
    $OMNIAUTH_PROVIDERS = {}.freeze

    load Rails.root.join('config/initializers/omniauth_providers_env.rb')

    assert $OMNIAUTH_PROVIDERS.key?(:keycloak)

    cfg = $OMNIAUTH_PROVIDERS[:keycloak]
    assert_equal :keycloak_openid, cfg[:strategy]
    assert_equal 'keycloak', cfg[:name]
    assert_equal 'keycloak.svg', cfg[:icon]
    assert_equal 'matportal-ui', cfg[:client_id]
    assert_equal 'secret123', cfg[:client_secret]
    assert_equal 'https://auth.example.org', cfg[:client_options][:site]
    assert_equal 'matportal', cfg[:client_options][:realm]
    assert_equal true, cfg[:enable]
    assert_equal 'Sign in with MatPortal Keycloak', cfg[:label]
  end

  test 'omniauth providers env respects KEYCLOAK_ENABLED false' do
    ENV['KEYCLOAK_SITE'] = 'https://auth.example.org'
    ENV['KEYCLOAK_REALM'] = 'matportal'
    ENV['KEYCLOAK_CLIENT_ID'] = 'matportal-ui'
    ENV['KEYCLOAK_CLIENT_SECRET'] = 'secret123'
    ENV['KEYCLOAK_ENABLED'] = 'false'

    $OMNIAUTH_PROVIDERS = {}.freeze

    load Rails.root.join('config/initializers/omniauth_providers_env.rb')

    assert $OMNIAUTH_PROVIDERS.key?(:keycloak)
    assert_equal false, $OMNIAUTH_PROVIDERS[:keycloak][:enable]
  end

  test 'omniauth providers env leaves providers unchanged when credentials are incomplete' do
    ENV['KEYCLOAK_SITE'] = 'https://auth.example.org'
    ENV['KEYCLOAK_REALM'] = 'matportal'
    ENV['KEYCLOAK_CLIENT_ID'] = 'matportal-ui'
    ENV.delete('KEYCLOAK_CLIENT_SECRET')

    $OMNIAUTH_PROVIDERS = { github: { client_id: 'gh-id', enable: true } }.freeze

    load Rails.root.join('config/initializers/omniauth_providers_env.rb')

    assert_equal true, $OMNIAUTH_PROVIDERS[:github][:enable]
    refute $OMNIAUTH_PROVIDERS.key?(:keycloak)
  end

  test 'omniauth providers env preserves existing per-portal options on keycloak' do
    ENV['KEYCLOAK_SITE'] = 'https://auth.example.org'
    ENV['KEYCLOAK_REALM'] = 'matportal'
    ENV['KEYCLOAK_CLIENT_ID'] = 'matportal-ui'
    ENV['KEYCLOAK_CLIENT_SECRET'] = 'secret123'

    $OMNIAUTH_PROVIDERS = {
      keycloak: {
        pkce: true,
        scope: 'openid profile',
        icon: 'custom.svg',
        name: 'kc_custom'
      }
    }.freeze

    load Rails.root.join('config/initializers/omniauth_providers_env.rb')

    cfg = $OMNIAUTH_PROVIDERS[:keycloak]
    assert_equal true, cfg[:pkce]
    assert_equal 'openid profile', cfg[:scope]
    assert_equal 'custom.svg', cfg[:icon]
    assert_equal 'kc_custom', cfg[:name]
    assert_equal 'https://auth.example.org', cfg[:client_options][:site]
    assert_equal 'matportal', cfg[:client_options][:realm]
  end

  test 'omniauth provider configuration skips disabled providers and forwards options via initializer' do
    $OMNIAUTH_PROVIDERS = {
      disabled_provider: {
        client_id: 'd-id',
        client_secret: 'd-sec',
        enable: false
      },
      fallback_provider: {
        client_id: 'fb-id',
        client_secret: 'fb-sec',
        enable: true
      },
      custom_keycloak: {
        strategy: :keycloak_openid,
        client_id: 'kc-id',
        client_secret: 'kc-sec',
        client_options: { site: 'https://auth.example.org', realm: 'kc' },
        name: 'keycloak',
        pkce: false,
        scope: 'openid email',
        enable: true
      }
    }.freeze

    captured_middleware = nil
    captured_block = nil
    middleware = Rails.application.config.middleware
    capture = lambda do |builder, &block|
      captured_middleware = builder
      captured_block = block
    end
    middleware.stub(:use, capture) do
      load Rails.root.join('config/initializers/omniauth.rb')
    end

    assert_equal OmniAuth::Builder, captured_middleware
    assert captured_block, 'OmniAuth::Builder block was not captured from middleware.use'

    recorder = Class.new do
      attr_reader :configured_providers

      def initialize
        @configured_providers = []
      end

      def provider(*args)
        @configured_providers << args
      end
    end.new

    recorder.instance_eval(&captured_block)

    # 1. Disabled provider is skipped
    assert_equal 2, recorder.configured_providers.size
    refute recorder.configured_providers.any? { |entry| entry.first == :disabled_provider }

    # 2. Other provider without strategy falls back to provider key
    fallback_entry = recorder.configured_providers.find { |entry| entry.first == :fallback_provider }
    refute_nil fallback_entry
    assert_equal 'fb-id', fallback_entry[1]
    assert_equal 'fb-sec', fallback_entry[2]
    assert_equal({ client_options: {} }, fallback_entry[3])

    # 3. Custom keycloak forwards strategy, client_id, client_secret, client_options, name, scope, and explicit pkce: false
    keycloak_entry = recorder.configured_providers.find { |entry| entry.first == :keycloak_openid }
    refute_nil keycloak_entry
    strategy, client_id, client_secret, options = keycloak_entry
    assert_equal :keycloak_openid, strategy
    assert_equal 'kc-id', client_id
    assert_equal 'kc-sec', client_secret
    assert_equal 'keycloak', options[:name]
    assert_equal false, options[:pkce]
    assert_equal 'openid email', options[:scope]
    assert_equal({ site: 'https://auth.example.org', realm: 'kc' }, options[:client_options])
  end

  test 'omniauth provider info and token provider resolve custom name, key, and strategy' do
    helper = Class.new { include ApplicationHelper }.new

    $OMNIAUTH_PROVIDERS = {
      keycloak: {
        strategy: :keycloak_openid,
        name: 'kc_custom',
        client_id: 'kc-client'
      }
    }.freeze

    # Custom name resolution
    assert_equal :keycloak, helper.omniauth_token_provider('kc_custom')
    assert_equal :keycloak, helper.omniauth_token_provider(:kc_custom)
    assert_equal [:keycloak], helper.omniauth_provider_info('kc_custom').keys
    assert_equal [:keycloak], helper.omniauth_provider_info(:kc_custom).keys

    # Provider key resolution
    assert_equal :keycloak, helper.omniauth_token_provider(:keycloak)
    assert_equal :keycloak, helper.omniauth_token_provider('keycloak')
    assert_equal [:keycloak], helper.omniauth_provider_info(:keycloak).keys
    assert_equal [:keycloak], helper.omniauth_provider_info('keycloak').keys

    # Strategy resolution
    assert_equal :keycloak, helper.omniauth_token_provider(:keycloak_openid)
    assert_equal :keycloak, helper.omniauth_token_provider('keycloak_openid')
    assert_equal [:keycloak], helper.omniauth_provider_info(:keycloak_openid).keys
    assert_equal [:keycloak], helper.omniauth_provider_info('keycloak_openid').keys

    # Unmatched provider returns nil / empty
    assert_nil helper.omniauth_token_provider(:unknown_provider)
    assert_equal({}, helper.omniauth_provider_info(:unknown_provider))
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
  end
end
