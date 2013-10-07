# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# memcache setup
config.cache_store = :mem_cache_store, 'localhost', { :namespace => 'BioPortal' }

begin
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     if forked
       # We're in smart spawning mode, so...
       # Close duplicated memcached connections - they will open themselves
      cache = Rails.cache.instance_variable_get("@data")
      cache.reset if cache && cache.respond_to?(:reset)
     end
   end
rescue NameError
  # In case you're not running under Passenger (i.e. devmode with mongrel)
end

# Don't allow downloaded files to be created as tempfiles. Force storage in memory using StringIO.
require 'open-uri'
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 104857600

# Include the BioPortal-specific configuration options
require RAILS_ROOT + '/config/bioportal_config.rb'
