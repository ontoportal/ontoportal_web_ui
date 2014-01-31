# Configure and initialize MiniProfiler
require 'rack-mini-profiler'
c = ::Rack::MiniProfiler.config
tmp = Rails.root.to_s + "/tmp/miniprofiler"
FileUtils.mkdir_p(tmp) unless File.exists?(tmp)
c.storage_options = {:path => tmp}
c.storage = ::Rack::MiniProfiler::FileStore
Rails.configuration.middleware.use(::Rack::MiniProfiler)
::Rack::MiniProfiler.profile_method(ActionController::Base, :process) {|action| "Executing action: #{action}"}
::Rack::MiniProfiler.profile_method(ActionView::Template, :render) {|x,y| "Rendering: #{@virtual_path}"}
::Rack::MiniProfiler.config.position = 'right'
::Rack::MiniProfiler.config.authorization_mode = :whitelist

# monkey patch away an activesupport and json_pure incompatability
# http://pivotallabs.com/users/alex/blog/articles/1332-monkey-patch-of-the-day-activesupport-vs-json-pure-vs-ruby-1-8
if JSON.const_defined?(:Pure)
  class JSON::Pure::Generator::State
    include ActiveSupport::CoreExtensions::Hash::Except
  end
end
