source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem "jquery-rails", "~> 2.1.3"
gem "haml", "~> 3.1.4"
gem "dynamic_form", "~> 1.1.4"
gem 'jeditable_wysiwyg_rails', :git => "git://github.com/pjmorse/jeditable-wysiwyg-rails.git"
# gem 'jeditable_wysiwyg_rails', :path => "/Users/pmorse/Projects/jeditable_wysiwyg_rails"
gem 'acts_as_list'
gem 'nested_form'
gem 'multi_json'
# authentication
gem 'devise'
# authorization
gem 'cancan'

gem 'default_value_for'
# Easy (or at least easier) database dumps and reloads
# Have to use a fork to cope with a bug: https://github.com/ludicast/yaml_db/issues/31
gem "yaml_db", :git => 'git://github.com/lostapathy/yaml_db.git'

gem "sqlite3"

group :production do
  gem 'mysql2'
  gem 'therubyracer',         "~>0.10.2"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem "rspec",       "~> 2.10.0"
  gem "rspec-rails", "~> 2.10.1"
  gem "ci_reporter", "~> 1.7.0"
  gem "factory_girl_rails"
  gem "faker"
  gem "capybara"

  gem 'pry'
  # Guard runs tests automatically when the files they test (or the tests
  # themselves) change
  gem 'guard-rspec'
  # rb-fsevent is a Guard dependency
  gem 'rb-fsevent'
  # Rspec formatter
  gem 'fuubar'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
