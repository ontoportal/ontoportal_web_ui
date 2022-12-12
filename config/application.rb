require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BioportalWebUi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Serve error pages from the Rails app itself, instead of using static error pages in /public.
    config.exceptions_app = self.routes

    config.settings = config_for :settings

    # Initialize configuration for KGCL change request functionality.
    config.change_request = config_for :change_request
  end
end
