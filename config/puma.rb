# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.

# Get the absolute path of the Rails application
deploy_root = File.expand_path("../..", __dir__)
shared_dir = "#{deploy_root}/shared"

# Puma threads
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `environment` that Puma will run in.
#
rails_env ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

# Close DB and cache connections before workers fork
before_fork do
  puts "Puma: Disconnecting before fork..."
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)

  if defined?(Rails.cache) && Rails.cache.respond_to?(:disconnect)
    Rails.cache.disconnect
  end
end

# Reconnect to DB and Memcached after forking
on_worker_boot do
  # If you are preloading your application and using Active Record, it's
  # recommended that you close any connections to the database before workers
  # are forked to prevent connection leakage.

  puts "Puma: Reconnecting after fork..."
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  if defined?(Rails.cache) && Rails.cache.respond_to?(:reset)
    Rails.cache.reset # For Dalli/Memcached
  end
end

if %w[production staging appliance].include?(rails_env)

  # Define Puma socket (for Nginx)
  bind "unix:///#{shared_dir}/tmp/sockets/puma.sock"

  # Specifies the number of `workers` to boot in clustered mode.
  # Workers are forked webserver processes. If using threads and workers together
  # the concurrency of the application would be max `threads` * `workers`.
  # Workers do not work on JRuby or Windows (both of which do not support
  # processes).

  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory. If you use this option
  # you need to make sure to reconnect any threads in the `on_worker_boot`

  preload_app!

  # PID & state file locations
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"
else
  # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
  port ENV.fetch("PORT") { 3000 }
end

# Logging setup
stdout_redirect "log/puma-#{rails_env}.stdout.log", "log/puma-#{rails_env}.stderr.log", true

# Allow puma to be restarted by `rails restart` command.
#
plugin :tmp_restart
