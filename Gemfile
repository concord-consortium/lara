source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'rails', '~> 3.2.19'
gem "jquery-rails"
gem 'jquery-ui-rails'
gem "haml"
gem "dynamic_form"
gem 'jeditable_wysiwyg_rails', :git => "git://github.com/pjmorse/jeditable-wysiwyg-rails.git"
# gem 'jeditable_wysiwyg_rails', :path => "/Users/pmorse/Projects/jeditable_wysiwyg_rails"
gem 'acts_as_list'
gem 'nested_form'
gem 'multi_json'
# authentication
gem 'devise'
# authorization
gem 'cancan'
gem 'omniauth'
# Github
gem 'omniauth-oauth2', :git => 'https://github.com/intridea/omniauth-oauth2.git'
gem 'default_value_for'

# Rails assets:
gem 'rails-assets-drawing-tool', '1.2.3'

# Easy (or at least easier) database dumps and reloads
# Have to use a fork to cope with a bug: https://github.com/ludicast/yaml_db/issues/31
gem "yaml_db", :git => 'git://github.com/lostapathy/yaml_db.git'
gem "aws-ses", "~> 0.5.0", :require => 'aws/ses'
gem 'uuidtools'
gem "httparty"
gem 'exception_notification'
gem 'newrelic_rpm'
gem 'shutterbug', '~>0.1.2'
# gem 'shutterbug', :path => "/Users/npaessel/lab/ruby/shutterbug"
# gem 'rack-environmental', :git => "git://github.com/pjmorse/rack-environmental.git", :branch => 'concord'
gem 'rack-environmental'
# gem 'sketchily', :path => "/Users/npaessellab/ruby/sketchily"
# use bundle update sketchily to force newest SHA from github, or uncomment above
# to work locally.
gem 'sketchily', :git => "git://github.com/concord-consortium/sketchily.git", :branch => "concord"
# We're not using sqlite in production, but moving this into the test/development groups
# causes problems.
gem "sqlite3"
gem 'mysql2'
gem "delayed_job_active_record"
gem "daemons"

# put font-awesome in asset pipeline. Alternately we could use a CDN.
gem "font-awesome-rails"
# Chosen jQuery plugin.
gem 'chosen-rails'

# this is to fix a pulled version of safe_yaml (0.9.4)
gem "safe_yaml", "~> 0.9.5"

# Paginate activities on activities page.
gem 'will_paginate', '~> 3.0'

# detect browser types
gem 'useragent'

group :production do
  gem 'therubyracer'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "turbo-sprockets-rails3"
end

group :test, :development do
  gem "rspec",       "~> 2.10.0"
  gem "rspec-rails", "~> 2.10.1"
  gem "ci_reporter", "~> 1.7.0"
  gem "factory_girl_rails"
  gem "faker"
  gem "capybara"
  gem "timecop"
  # Guard runs tests automatically when the files they test (or the tests
  # themselves) change
  gem 'guard-rspec'
  # rb-fsevent is a Guard dependency
  gem 'rb-fsevent'
  # Rspec formatter
  gem 'fuubar'
  # Javascript tests with PhantomJS
  gem 'poltergeist'
  # JS unit tests
  gem 'jasmine'
  gem 'jasmine-ajax'
  gem 'guard-jasmine'
  gem 'jasminerice', :git => "git://github.com/bradphelan/jasminerice.git" # guard-jasmine uses this
  gem 'jasmine-jquery-rails'
end

group :test do
  # test webservices
  gem 'webmock'
  # needed for capybara's save_and_open_page
  gem 'launchy'
end

group :development do
  gem "binding_of_caller"
  gem 'pry'
  gem 'pry-stack_explorer'
  #gem 'pry-exception_explorer'
  gem 'pry-debugger'
  # Evaluate database query efficiency
  gem 'bullet'
  gem 'better_errors'
  gem "sextant"    # adds http://localhost:9000/rails/routes in dev mode
  gem "xray-rails" #cmd+shift+x in browser shows your view partials.
  gem "rack-mini-profiler"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'capistrano-autoscaling', '0.0.8', :git => "git://github.com/concord-consortium/capistrano-autoscaling.git", :branch => "concord"
# gem 'capistrano-autoscaling', '0.0.8', :path => "/Users/npaessel/lab/cc/capistrano-autoscaling"

# add some tools for 
# Tools
# Security scan
gem 'brakeman', :require => false
# Log analysis
gem 'request-log-analyzer', :require => false
# Database analysis
gem 'lol_dba', :require => false
