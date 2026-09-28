# frozen_string_literal: true

require 'uri'

module AnalyticsHelper
  DEFAULT_CONSENT_COOKIE_NAME = 'analytics_consent'.freeze
  CONSENT_COOKIE_EXPIRY = 6.months
  def analytics_provider
    resolved_analytics_provider
  end

  def resolved_analytics_provider
    explicit = configured_analytics_provider
    return explicit_provider(explicit) unless explicit.nil?

    return 'google' if google_analytics_tag_id.present?
    return 'matomo' if matomo_configured?

    nil
  end

  def analytics_enabled?
    case resolved_analytics_provider
    when 'google'
      google_analytics_tag_id.present?
    when 'matomo'
      matomo_configured?
    else
      false
    end
  end

  def analytics_tracking_enabled?
    analytics_enabled? && analytics_consented?
  end

  def analytics_consent_required?
    return false unless analytics_enabled?

    strict_boolean(analytics_configuration_value('ANALYTICS_REQUIRE_CONSENT',
                                                  (defined?($ANALYTICS_REQUIRE_CONSENT) ? $ANALYTICS_REQUIRE_CONSENT : nil),
                                                  :require_consent),
                   default: true)
  end

  def extended_cookie_consent_enabled?
    analytics_enabled? && analytics_consent_required?
  end

  def analytics_consented?
    return true unless analytics_consent_required?

    cookies[analytics_consent_cookie_name].to_s == 'true'
  end

  def show_cookie_consent_banner?
    extended_cookie_consent_enabled? && cookies[analytics_consent_cookie_name].nil?
  end

  def analytics_consent_cookie_name
    DEFAULT_CONSENT_COOKIE_NAME
  end

  def analytics_consent_cookie_domain
    domain = analytics_configuration_value('ANALYTICS_CONSENT_COOKIE_DOMAIN',
                                            (defined?($ANALYTICS_CONSENT_COOKIE_DOMAIN) ? $ANALYTICS_CONSENT_COOKIE_DOMAIN : nil),
                                            :consent_cookie_domain).to_s.strip
    return nil if domain.blank?
    return nil unless domain.length <= 253 && domain.match?(/\A\.?[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?\z/)
    return nil if domain.include?('..')

    normalized_domain = domain.downcase
    cookie_domain = normalized_domain.delete_prefix('.')
    host = request.host.to_s.downcase
    return nil unless host == cookie_domain || host.end_with?(".#{cookie_domain}")

    normalized_domain
  end

  def google_analytics_tag_id
    credentials_id = Rails.application.credentials.dig(:google_analytics, :tag_id)
    value = [credentials_id,
             ENV['ANALYTICS_ID'],
             (defined?($ANALYTICS_ID) ? $ANALYTICS_ID : nil),
             analytics_settings_value(:google, :tag_id)].find { |item| configured_value?(item) }
    value.to_s.strip.presence
  rescue StandardError
    nil
  end

  def matomo_configured?
    matomo_tracking_base_url.present? && matomo_site_id.present?
  end

  def matomo_tracking_base_url
    normalize_matomo_url(analytics_configuration_value('MATOMO_URL',
                                                        (defined?($MATOMO_URL) ? $MATOMO_URL : nil),
                                                        :matomo, :url))
  end

  def matomo_site_id
    value = analytics_configuration_value('MATOMO_SITE_ID',
                                          (defined?($MATOMO_SITE_ID) ? $MATOMO_SITE_ID : nil),
                                          :matomo, :site_id).to_s.strip
    value.match?(/\A[1-9]\d*\z/) ? value : nil
  end

  private

  def configured_analytics_provider
    value = analytics_configuration_value('ANALYTICS_PROVIDER',
                                          (defined?($ANALYTICS_PROVIDER) ? $ANALYTICS_PROVIDER : nil),
                                          :provider)
    return nil unless configured_value?(value)

    value.to_s.strip.downcase
  end

  def explicit_provider(provider)
    case provider
    when 'google'
      google_analytics_tag_id.present? ? 'google' : nil
    when 'matomo'
      matomo_configured? ? 'matomo' : nil
    when 'none'
      nil
    else
      nil
    end
  end

  def analytics_configuration_value(environment_name, global_value, *settings_path)
    values = [ENV[environment_name], global_value, analytics_settings_value(*settings_path)]
    values.find { |value| configured_value?(value) }
  end

  def configured_value?(value)
    !value.nil? && !(value.is_a?(String) && value.strip.empty?)
  end

  def strict_boolean(value, default:)
    return value if value == true || value == false
    return default unless configured_value?(value)

    case value.to_s.strip.downcase
    when 'true' then true
    when 'false' then false
    else default
    end
  end

  def normalize_matomo_url(value)
    return nil unless configured_value?(value)

    uri = URI.parse(value.to_s.strip)
    return nil unless %w[http https].include?(uri.scheme) && uri.host.present?

    uri.query = nil
    uri.fragment = nil
    uri.path = uri.path.to_s.sub(%r{/+\z}, '')
    uri.to_s.sub(%r{/+\z}, '')
  rescue URI::InvalidURIError
    nil
  end

  def analytics_settings_value(*path)
    return nil unless Rails.configuration.respond_to?(:settings)

    value = config_value(Rails.configuration.settings, :analytics)
    path.each do |key|
      value = config_value(value, key)
      return nil if value.nil?
    end
    value
  rescue StandardError
    nil
  end

  def config_value(value, key)
    return nil if value.nil?
    return value[key] if value.respond_to?(:key?) && value.key?(key)
    return value[key.to_s] if value.respond_to?(:key?) && value.key?(key.to_s)
    return value.public_send(key) if value.respond_to?(key)

    nil
  end
end
