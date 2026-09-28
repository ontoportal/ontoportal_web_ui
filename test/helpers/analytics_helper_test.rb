# frozen_string_literal: true

require 'test_helper'

class AnalyticsHelperTest < ActionView::TestCase
  include AnalyticsHelper

  CONFIG_ENV = %w[
    ANALYTICS_PROVIDER
    ANALYTICS_REQUIRE_CONSENT
    ANALYTICS_CONSENT_COOKIE_DOMAIN
    ANALYTICS_ID
    MATOMO_URL
    MATOMO_SITE_ID
  ].freeze

  setup do
    @original_env = CONFIG_ENV.to_h { |key| [key, ENV[key]] }
    @original_settings = Rails.configuration.settings[:analytics].deep_dup
    @original_globals = {
      provider: $ANALYTICS_PROVIDER,
      id: $ANALYTICS_ID,
      matomo_url: $MATOMO_URL,
      matomo_site_id: $MATOMO_SITE_ID,
      require_consent: $ANALYTICS_REQUIRE_CONSENT,
      cookie_domain: $ANALYTICS_CONSENT_COOKIE_DOMAIN
    }
    clear_configuration
    @cookies = {}
  end

  teardown do
    CONFIG_ENV.each { |key| ENV[key] = @original_env[key] }
    Rails.configuration.settings[:analytics] = @original_settings
    $ANALYTICS_PROVIDER = @original_globals[:provider]
    $ANALYTICS_ID = @original_globals[:id]
    $MATOMO_URL = @original_globals[:matomo_url]
    $MATOMO_SITE_ID = @original_globals[:matomo_site_id]
    $ANALYTICS_REQUIRE_CONSENT = @original_globals[:require_consent]
    $ANALYTICS_CONSENT_COOKIE_DOMAIN = @original_globals[:cookie_domain]
  end

  test 'consent cookie name is fixed' do
    assert_equal AnalyticsHelper::DEFAULT_CONSENT_COOKIE_NAME, analytics_consent_cookie_name
  end

  test 'no provider configuration disables analytics' do
    assert_nil resolved_analytics_provider
    assert_not analytics_enabled?
  end

  test 'existing Google configuration remains the default provider' do
    ENV['ANALYTICS_ID'] = 'G-EXISTING'

    assert_equal 'google', resolved_analytics_provider
    assert_equal 'G-EXISTING', google_analytics_tag_id
    assert analytics_tracking_enabled?
  end

  test 'Matomo is inferred only when Google is not configured' do
    ENV['MATOMO_URL'] = ' https://analytics.example.org/matomo/?ignored=1#fragment/ '
    ENV['MATOMO_SITE_ID'] = '42'

    assert_equal 'matomo', resolved_analytics_provider
    assert_equal 'https://analytics.example.org/matomo', matomo_tracking_base_url
    assert_equal '42', matomo_site_id
  end

  test 'explicit providers select only the requested configured provider' do
    ENV['ANALYTICS_ID'] = 'G-EXISTING'
    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo'
    ENV['MATOMO_SITE_ID'] = '42'

    ENV['ANALYTICS_PROVIDER'] = 'matomo'
    assert_equal 'matomo', resolved_analytics_provider

    ENV['ANALYTICS_PROVIDER'] = 'google'
    assert_equal 'google', resolved_analytics_provider
  end

  test 'none and invalid explicit providers fail closed without fallback' do
    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo'
    ENV['MATOMO_SITE_ID'] = '42'

    ENV['ANALYTICS_PROVIDER'] = 'none'
    assert_nil resolved_analytics_provider
    assert_not analytics_enabled?

    ENV['ANALYTICS_PROVIDER'] = 'invalid'
    assert_nil resolved_analytics_provider
    assert_not analytics_enabled?
    assert_not extended_cookie_consent_enabled?
  end

  test 'Matomo requires an HTTP(S) URL with a host and a positive site id' do
    ENV['MATOMO_URL'] = 'javascript:alert(1)'
    ENV['MATOMO_SITE_ID'] = '42'
    assert_nil matomo_tracking_base_url
    assert_not analytics_enabled?

    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo'
    ENV['MATOMO_SITE_ID'] = 'missing'
    assert_nil matomo_site_id
    assert_not analytics_enabled?
  end

  test 'false environment consent setting overrides true settings' do
    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo'
    ENV['MATOMO_SITE_ID'] = '42'
    Rails.configuration.settings[:analytics][:require_consent] = true
    ENV['ANALYTICS_REQUIRE_CONSENT'] = 'false'

    assert_not analytics_consent_required?
  end

  test 'required consent gates tracking on the exact accepted cookie value' do
    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo'
    ENV['MATOMO_SITE_ID'] = '42'
    ENV['ANALYTICS_REQUIRE_CONSENT'] = 'true'

    assert_not analytics_tracking_enabled?
    @cookies['analytics_consent'] = 'false'
    assert_not analytics_tracking_enabled?
    @cookies['analytics_consent'] = 'true'
    assert analytics_tracking_enabled?
  end

  test 'consent cookie domain matches the exact host or a subdomain case-insensitively' do
    request.set_header('HTTP_HOST', 'STAGE.MATPORTAL.ORG')
    ENV['ANALYTICS_CONSENT_COOKIE_DOMAIN'] = 'stage.matportal.org'
    assert_equal 'stage.matportal.org', analytics_consent_cookie_domain

    request.set_header('HTTP_HOST', 'chemistry.STAGE.MATPORTAL.ORG')
    ENV['ANALYTICS_CONSENT_COOKIE_DOMAIN'] = '.STAGE.MATPORTAL.ORG'
    assert_equal '.stage.matportal.org', analytics_consent_cookie_domain
  end

  test 'malformed and unrelated consent cookie domains fall back to host-only' do
    request.set_header('HTTP_HOST', 'chemistry.stage.matportal.org')
    assert_nil analytics_consent_cookie_domain

    ['.stage..matportal.org', '.other.example.org', 'https://stage.matportal.org'].each do |domain|
      ENV['ANALYTICS_CONSENT_COOKIE_DOMAIN'] = domain
      assert_nil analytics_consent_cookie_domain
    end
  end

  private

  def cookies
    @cookies
  end

  def clear_configuration
    CONFIG_ENV.each { |key| ENV.delete(key) }
    $ANALYTICS_PROVIDER = nil
    $ANALYTICS_ID = nil
    $MATOMO_URL = nil
    $MATOMO_SITE_ID = nil
    $ANALYTICS_REQUIRE_CONSENT = nil
    $ANALYTICS_CONSENT_COOKIE_DOMAIN = nil
  end
end
