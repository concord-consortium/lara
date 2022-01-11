source "https://rubygems.org"

group :production do
  gem "unicorn"
end

group :assets do
  gem "sass-rails", "~> 3.2"
  gem "coffee-rails", "~> 3.2"
  gem "compass-rails", "~> 3.0"
  gem "compass-blueprint", "~> 1.0"
  gem "uglifier", "~> 4.1"
  gem "turbo-sprockets-rails3", "~> 0.3"
end

# 2021-11-01 -- NP: rails-assets.org SSL certificate has expired.
# For now we have just put the JS and CSS files for drawing tool and its deps
# into app/assets/javascript & app/assets/css
# however managing those dependencies isn't going to be easy. We need a better
# long term solution
#
# source 'https://rails-assets.org' do
#   gem 'rails-assets-drawing-tool', '1.3.2'
#   gem 'rails-assets-modulejs', '1.6.0'
# end

group :development do
  gem "binding_of_caller", "~> 0.7"
  # bullet 5.5 does not support AR 3
  gem 'bullet', '~> 5.4.3', '>= 5.4.3'
  gem "better_errors", "~> 1.1"
  gem "sextant", "~> 0.2"
  gem "xray-rails", "~> 0.1"
  gem "guard-rspec", "~> 4.6", {:require=>false}
  gem "quiet_assets", "~> 1.1"
  gem "webrick", "~> 1.3"
  gem "capistrano", "~> 2.15"
  gem "aws-sdk", "~> 1.66"
  gem "capistrano-autoscaling", "~> 0.0", {:git=>"https://github.com/concord-consortium/capistrano-autoscaling.git", :branch=>"concord"}
  gem "capistrano-cowboy", "~> 0.1"
  gem "lol_dba", "~> 1.6", {:require=>false}
  gem "brakeman", "~> 2.4", {:require=>false}
  gem "request-log-analyzer", "~> 1.12", {:require=>false}
end

group :test do
  gem "webmock", "~> 1.20"
  gem 'simplecov', require: false
end

group :test, :development do
  gem "rb-fsevent", "~> 0.9"
  gem "spring-commands-rspec", "~> 1.0"
  gem "spring", "~> 1.2"
  gem "test-unit", "~> 3.0"
  gem "rspec-rails", "~> 3.8"
  gem "rspec-activemodel-mocks", "~> 1.0"
  gem "ci_reporter", "~> 1.7"
  gem "factory_girl_rails", "~> 4.3", {:require=>false}
  gem "faker", "~> 1.2"
  gem "capybara", "~> 2.4"
  gem "timecop", "~> 0.6"
  gem "poltergeist", "~> 1.5"
  gem "jasmine", "~> 2.2"
  gem "jasmine-jquery-rails", "~> 2.0"
  gem "launchy", "~> 2.4"
  gem "pry"
  gem 'pry-byebug'
end

gem "highline", "~> 1.6"
source 'https://gems.railslts.com' do
  gem 'rails', '~> 3.2.22'
  gem 'actionmailer',     :require => false
  gem 'actionpack',       :require => false
  gem 'activemodel',      :require => false
  gem 'activerecord',     :require => false
  gem 'activeresource',   :require => false
  gem 'activesupport',    :require => false
  gem 'railties',         :require => false
  gem 'railslts-version', :require => false
end
gem 'rake', '< 11'
gem "jquery-rails", "~> 3.1.3"
gem "jquery-ui-rails", "~> 4.1"
gem "haml", "~> 4.0"
gem "dynamic_form", "~> 1.1"
gem "acts_as_list", "~> 0.3"
gem "nested_form", "~> 0.3"
gem "gon", "~> 5.2"
gem "multi_json", "~> 1.11"
gem "devise", "~> 3.0"
gem "cancancan", "~> 1.10"
gem "omniauth", "~> 1.3.2"
gem "omniauth-oauth2", "~> 1.1", {:git=>"https://github.com/intridea/omniauth-oauth2.git"}
gem "default_value_for", "~> 2.0"
gem "tinymce-rails", "~> 4.7"
gem "yaml_db", "~> 0.2", {:git=>"https://github.com/lostapathy/yaml_db.git"}
gem "aws-ses", git: "https://github.com/zebitex/aws-ses.git", ref: "78-sigv4-problem"
gem "uuidtools", "~> 2.1"
gem "httparty", "~> 0.12"
gem "exception_notification", "~> 4.0"
gem 'newrelic_rpm', '~> 4.6', '>= 4.6.0.338'
gem "rack-environmental", "~> 1.3"
gem "sqlite3", "~> 1.3"
gem "mysql2", "~> 0.3"
gem "delayed_job_active_record", "~> 4.0"
gem "delayed_job_web", "~> 1.2"
gem "daemons", "~> 1.1"
gem "font-awesome-rails", "~> 4.3"
gem "chosen-rails", "~> 1.0"
gem "safe_yaml", "~> 1.0"
gem "will_paginate", "~> 3.0"
gem "useragent", "~> 0.10"
gem "ribbons-rails", "~> 0.0", {:git=>"https://github.com/concord-consortium/ribbons-rails.git"}
gem "spreadsheet", "~> 1.0"
gem "nokogiri", ">= 1.8.5"
gem "rack-cors","~> 0.4.1", :require => 'rack/cors'
gem "test-unit", "~> 3.0"
gem 'rack-secure_samesite_cookies', {:git => 'https://github.com/concord-consortium/secure-samesite-cookies.git', :tag => 'v1.0.2'}