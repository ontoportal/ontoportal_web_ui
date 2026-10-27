# frozen_string_literal: true

class CookieConsentController < ApplicationController
  include AnalyticsHelper

  layout :determine_layout

  def show
    redirect_to root_path unless extended_cookie_consent_enabled?
  end

  def update
    analytics_allowed = analytics_consent_param
    return invalid_consent_request unless analytics_allowed == true || analytics_allowed == false

    remember_cookie_consent(analytics_allowed)

    if request.format.json?
      render json: { cookies_accepted: true, analytics_consent: analytics_allowed }
    else
      redirect_back fallback_location: root_path, status: :see_other
    end
  end

  private

  def analytics_consent_param
    value = if params.key?(:analytics_consent)
              params[:analytics_consent]
            elsif params.key?(:analytics_preference)
              params[:analytics_preference]
            end

    return value if value == true || value == false
    return true if value == 'true'
    return false if value == 'false'

    nil
  end

  def invalid_consent_request
    if request.format.json?
      render json: { error: 'analytics_consent must be true or false' }, status: :unprocessable_entity
    else
      render plain: 'analytics_consent must be true or false', status: :unprocessable_entity
    end
  end

  def remember_cookie_consent(analytics_allowed)
    write_consent_cookie('cookies_accepted', 'true')
    write_consent_cookie(analytics_consent_cookie_name, analytics_allowed ? 'true' : 'false')
  end

  def write_consent_cookie(name, value)
    options = {
      value: value,
      expires: AnalyticsHelper::CONSENT_COOKIE_EXPIRY.from_now,
      path: '/',
      httponly: false,
      same_site: :lax,
      secure: request.ssl?
    }
    options[:domain] = analytics_consent_cookie_domain if analytics_consent_cookie_domain
    cookies[name] = options
  end
end
