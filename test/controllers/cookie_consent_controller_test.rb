# frozen_string_literal: true

require 'test_helper'

class CookieConsentControllerTest < ActionDispatch::IntegrationTest
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
    @original_footer_links = $FOOTER_LINKS
    clear_configuration
    $FOOTER_LINKS = Marshal.load(Marshal.dump(@original_footer_links))
    $FOOTER_LINKS[:sections][:agreements][:privacy_policy] = 'https://privacy.example/portal'
  end

  teardown do
    CONFIG_ENV.each { |key| ENV[key] = @original_env[key] }
    Rails.configuration.settings[:analytics] = @original_settings
    $FOOTER_LINKS = @original_footer_links
  end

  test 'valid JSON acceptance writes both consent cookies' do
    configure_matomo

    post cookie_consent_path,
         params: { analytics_consent: 'true' },
         headers: { 'ACCEPT' => 'application/json' }

    assert_response :success
    assert_equal({ 'cookies_accepted' => true, 'analytics_consent' => true }, JSON.parse(response.body))
    assert_includes response.headers['Set-Cookie'], 'cookies_accepted=true'
    assert_includes response.headers['Set-Cookie'], 'analytics_consent=true'
  end

  test 'valid JSON rejection stores false consent' do
    configure_matomo

    post cookie_consent_path,
         params: { analytics_consent: 'false' },
         headers: { 'ACCEPT' => 'application/json' }

    assert_response :success
    assert_equal false, JSON.parse(response.body)['analytics_consent']
    assert_includes response.headers['Set-Cookie'], 'analytics_consent=false'
  end

  test 'canonical reject wins over preference fallback' do
    configure_matomo

    post cookie_consent_path,
         params: { analytics_consent: 'false', analytics_preference: 'true' },
         headers: { 'ACCEPT' => 'application/json' }

    assert_response :success
    assert_equal false, JSON.parse(response.body)['analytics_consent']
  end

  test 'missing, malformed, numeric, and array values are rejected without consent cookies' do
    configure_matomo

    [
      {},
      { analytics_consent: 'maybe' },
      { analytics_consent: 1 },
      { analytics_consent: ['true', 'false'] }
    ].each do |params|
      post cookie_consent_path, params: params, headers: { 'ACCEPT' => 'application/json' }
      assert_response :unprocessable_entity
      assert_equal 422, response.status
      assert_no_match(/cookies_accepted|analytics_consent/, response.headers['Set-Cookie'].to_s)
    end
  end

  test 'matching domain is applied to both consent cookies' do
    configure_matomo
    host! 'chemistry.STAGE.MATPORTAL.ORG'
    ENV['ANALYTICS_CONSENT_COOKIE_DOMAIN'] = '.STAGE.MATPORTAL.ORG'

    post cookie_consent_path,
         params: { analytics_consent: 'true' },
         headers: { 'ACCEPT' => 'application/json' }

    assert_response :success
    set_cookie = response.headers['Set-Cookie']
    assert_equal 2, set_cookie.scan(/domain=\.stage\.matportal\.org/i).length
  end

  test 'unrelated domain falls back to a host-only cookie that persists' do
    configure_matomo
    host! 'chemistry.stage.matportal.org'
    ENV['ANALYTICS_CONSENT_COOKIE_DOMAIN'] = '.other.example.org'

    post cookie_consent_path,
         params: { analytics_consent: 'true' },
         headers: { 'ACCEPT' => 'application/json' }

    assert_response :success
    set_cookie = response.headers['Set-Cookie']
    assert_no_match(/(?:^|;)\s*domain=/i, set_cookie)
    assert_not_includes set_cookie.downcase, '.other.example.org'

    get cookie_consent_path

    assert_response :success
    assert_select '#analytics-preference[checked]'
    assert_includes response.body, 'analytics.example.org/matomo'
  end

  test 'manage page uses the portal privacy URL and shows controls' do
    configure_matomo

    get cookie_consent_path

    assert_response :success
    assert_select 'a[href="https://privacy.example/portal#h-privacy-policy"]'
    assert_select 'form[action="/cookie_consent"]', minimum: 3
    assert_select 'input[name="analytics_consent"]', minimum: 3
    assert_select 'input#analytics-preference'
  end

  test 'accepted Google tracking remains Google-only' do
    ENV['ANALYTICS_ID'] = 'G-EXISTING'
    ENV['ANALYTICS_REQUIRE_CONSENT'] = 'true'
    cookies['analytics_consent'] = 'true'

    get cookie_consent_path

    assert_response :success
    assert_includes response.body, 'googletagmanager.com/gtag/js?id=G-EXISTING'
    assert_includes response.body, "gtag('config', \"G-EXISTING\")"
    assert_no_match(/matomo\.(?:js|php)/, response.body)
  end

  test 'Matomo markup is absent before consent and present after acceptance' do
    configure_matomo

    get cookie_consent_path
    assert_response :success
    assert_no_match(/matomo\.(?:js|php)/, response.body)

    cookies['analytics_consent'] = 'true'
    get cookie_consent_path
    assert_response :success
    assert_includes response.body, 'analytics.example.org/matomo'
    assert_includes response.body, "g.src = u + 'matomo.js'"
    assert_includes response.body, 'analytics.example.org/matomo/matomo.php'
  end

  test 'rejected consent renders no Matomo request markup and keeps manage link' do
    configure_matomo
    cookies['analytics_consent'] = 'false'

    get cookie_consent_path

    assert_response :success
    assert_no_match(/matomo\.(?:js|php)/, response.body)
    assert_select 'script[src*="cookie_consent"]'
    assert_select 'a[href="/cookie_consent"]', text: 'Manage cookie preferences'
  end

  test 'legacy cookies endpoint remains available when extended consent is off' do
    get cookies_path

    assert_response :success
    assert_includes response.body, 'Manage Cookie Consent'
    assert_includes response.body, 'Privacy policy'
  end

  private

  def configure_matomo
    ENV['MATOMO_URL'] = 'https://analytics.example.org/matomo/'
    ENV['MATOMO_SITE_ID'] = '42'
    ENV['ANALYTICS_REQUIRE_CONSENT'] = 'true'
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
