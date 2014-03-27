# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Add custom data attributes to sanitize allowed list
config.action_view.sanitized_allowed_attributes = 'id', 'class', 'style', 'data-cls', 'data-ont'

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Autoload the lib folder in development
config.autoload_paths << "#{config.root_path}/lib"

# Show log when using different rack servers
config.middleware.use Rails::Rack::LogTailer

# memcache setup
# config.cache_store = :memory_store
config.cache_store = ActiveSupport::Cache::MemCacheStore.new('localhost', namespace: 'BioPortal')
config.cache_store.logger = Logger.new("/dev/null")

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
