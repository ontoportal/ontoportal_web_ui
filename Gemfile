# Required gems
source 'https://rubygems.org'

gem "rails", "2.3.17"

gem "pry"
gem "iconv"
gem "hpricot", "~> 0.8.6"
gem "recaptcha", "~> 0.3.1"
gem "rest-client", "~> 1.6.1"
gem "mysql", "~> 2.8.1"
gem "memcache-client", "~> 1.8.5"
gem "i18n", "~> 0.5.0"
gem "haml", "< 4.0.0"
gem "will_paginate", "< 3.0"
gem "rdoc"
# Update rack-mini-profiler to fix missing jQuery error, i.e.
# https://github.com/MiniProfiler/rack-mini-profiler/issues/29
gem "rack-mini-profiler", :github => 'MiniProfiler/rack-mini-profiler'
gem 'cube-ruby', require: 'cube'
gem 'oink'

gem 'ncbo_resolver', git: "https://github.com/ncbo/ncbo_resolver.git"
gem 'ontologies_api_client', :git => "https://github.com/ncbo/ontologies_api_ruby_client.git"

group :development do
  gem "thin"
  gem "unicorn"
end
