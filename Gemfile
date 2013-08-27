source 'https://rubygems.org'

gem 'rails', '3.2.13'
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
gem 'omniauth-oauth2'
gem 'default_value_for'

# Easy (or at least easier) database dumps and reloads
# Have to use a fork to cope with a bug: https://github.com/ludicast/yaml_db/issues/31
gem "yaml_db", :git => 'git://github.com/lostapathy/yaml_db.git'

gem 'uuidtools'
gem "httparty"
gem 'airbrake'
gem 'exception_notification'
gem 'shutterbug', '~>0.0.11'
# gem 'shutterbug', :path => "/Users/npaessel/lab/ruby/shutterbug"
gem 'rack-environmental', :git => "git://github.com/pjmorse/rack-environmental.git"
# gem 'sketchily', :path => "/Users/npaessel/lab/ruby/sketchily"
# use bundle update sketchily to force newest SHA from github, or uncomment above
# to work locally.
gem 'sketchily', :git => "git://github.com/concord-consortium/sketchily.git", :branch => "concord"
# We're not using sqlite in production, but moving this into the test/development groups
# causes problems.
gem "sqlite3"

group :production do
  gem 'mysql2'
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

  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-exception_explorer'
  gem 'pry-debugger'
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
  gem 'guard-jasmine'
  gem 'jasminerice' # guard-jasmine uses this
end

group :test do
  # test webservices
  gem 'webmock'
  # needed for capybara's save_and_open_page
  gem 'launchy'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

gem 'brakeman', :require => false

# put font-awesome in asset pipeline Alternately we could use a CDN.
gem "font-awesome-rails"

# this is to fix a pulled version of safe_yaml (0.9.4)
gem "safe_yaml", "~> 0.9.5"
