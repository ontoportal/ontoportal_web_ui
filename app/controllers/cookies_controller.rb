# frozen_string_literal: true

class CookiesController < ApplicationController
  def index; end

  def consent
    cookies[:allow_cookies] = { value: params[:consent], expires: 1.year.from_now }
    render turbo_stream: turbo_stream.remove(:cookie_consent)
  end
end
