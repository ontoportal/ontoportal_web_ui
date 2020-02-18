source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.7'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.0.3'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# gem 'duktape'

gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'bootstrap', '~> 4.1.0'
gem 'chart-js-rails'
gem 'select2-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'debugger'

gem "pry"
gem "iconv"
gem "recaptcha", "~> 5.2"
gem "rest-client", "~> 1.8.0"
gem "mysql2", "0.5.2"
gem "i18n"
gem "haml", "~> 5.1"
gem "will_paginate", "~> 3.0"
gem "rdoc"
gem "rack-mini-profiler"
gem "flamegraph"
gem "stackprof", :require => false
gem 'cube-ruby', require: 'cube'
gem 'oj'
gem 'multi_json'
gem 'rails_autolink'
gem 'dalli'
gem 'thin'
gem 'open_uri_redirections'
gem 'nokogiri'

gem 'ontologies_api_client', :git => "https://github.com/ncbo/ontologies_api_ruby_client.git", branch: "staging"

group :staging, :production do
  # application monitoring
  gem 'newrelic_rpm'
  #logs in json format, useful for shipping logs to logstash
  # gem 'rackstash', git: "https://github.com/planio-gmbh/rackstash.git"
  # gem 'logstash-logger'
end

group :development do
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-locally', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-yarn', require: false
  gem 'html2haml'
  # static code analysis
  gem "brakeman", require: false
  gem "rubocop", require: false
  # gem 'i18n-debug'
end
