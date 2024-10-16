# source 'https://gems.railslts.com' do
  gem 'actionmailer', :require => false
  gem 'actionpack', :require => false
  gem 'activemodel', :require => false
  gem 'activerecord', :require => false
  gem 'activeresource',   :require => false
  gem 'activesupport', :require => false
  gem 'rails', '~> 4.0.13'
  gem 'railslts-version', :require => false
  gem 'railties', :require => false
# end

source "https://rubygems.org"

group :production do
  gem "unicorn"
end

group :assets do
  gem "coffee-rails", '~> 4.2', '>= 4.2.2'
  gem "compass-blueprint", "~> 1.0"
  gem "compass-rails", "~> 3.1.0"
  gem "sass-rails", "~> 5.0", ">= 5.0.7"
  gem "turbo-sprockets-rails4", "~> 1.2.5"
  gem "uglifier", "~> 4.2"
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
  gem "better_errors", "~> 2.0.0", ">= 2.0.0"
  # gem "binding_of_caller", "~> 0.7"
  # gem "brakeman", "~> 2.4", {:require=>false}
  gem 'bullet', "~> 4.14.10"
  # gem "capistrano", "~> 2.15"
  # gem "capistrano-autoscaling", "~> 0.0", {:git=>"https://github.com/concord-consortium/capistrano-autoscaling.git", :branch=>"concord"}
  # gem "capistrano-cowboy", "~> 0.1"
  # gem "guard-rspec", "~> 4.6", {:require=>false}
  # gem "lol_dba", "~> 1.6", {:require=>false}
  # gem "quiet_assets", "~> 1.1"
  # gem "request-log-analyzer", "~> 1.12", {:require=>false}
  # gem "sextant", "~> 0.2"
  # gem "webrick", "~> 1.3"
  # gem "xray-rails", "~> 0.1"
end

group :test do
  gem 'simplecov', require: false
  gem "webmock", "~> 3.18", ">= 3.18.1"
end

group :test, :development do
  gem "capybara", "~> 2.18"
  # gem "ci_reporter", "~> 1.9.2"
  gem "factory_girl_rails", "~> 4.5", ">= 4.5.0", :require=>false
  gem "faker", "~> 2.2", ">= 2.2.1"
  gem "jasmine", "~> 3.8"
  gem "jasmine-jquery-rails", "~> 2.0", ">= 2.0.3"
  gem "launchy", "~> 2.5", ">= 2.5.2"
  gem "poltergeist", "~> 1.18", ">= 1.18.1"
  # gem "pry"
  # gem 'pry-byebug'
  # gem "rb-fsevent", "~> 0.9"
  gem "rspec-activemodel-mocks", '~> 1.2', '>= 1.2.1'
  gem "rspec-rails", '~> 3.8'
  gem "spring", "~> 1.7", ">= 1.7.2"
  gem "spring-commands-rspec", "~> 1.0", ">= 1.0.4"
  gem "test-unit", "~> 3.6", ">= 3.6.2"
  gem "timecop", "~> 0.9", ">= 0.9.10"
end

gem "acts_as_list", '~> 0.9.19'
gem "aws-sdk", "~> 3.1"
gem "aws-ses", "0.7.1", git: "https://github.com/zebitex/aws-ses.git", ref: "78-sigv4-problem"
gem "cancancan", "~> 1.17"
gem "chosen-rails", "~> 1.10"
gem "daemons", "~> 1.4", ">= 1.4.1"
gem "default_value_for", "~> 3.6"
gem "delayed_job_active_record", '~> 4.1', '>= 4.1.10'
gem "delayed_job_web", '~> 1.4', '>= 1.4.4'
gem "devise", '~> 3.5', '>= 3.5.10'
gem "dynamic_form", "~> 1.2"
gem "exception_notification", '~> 4.4', '>= 4.4.3'
gem "font-awesome-rails", '~> 4.7', '>= 4.7.0.8'
gem "gon", "~> 6.4.0"
gem "haml", "~> 4.0.7"
gem "highline", "~> 2.1"
gem "httparty", "~> 0.21"
gem "jquery-rails", '~> 3.1', '>= 3.1.5'
gem "jquery-ui-rails", '~> 4.2.1'
gem "multi_json", "~> 1.15"
gem "mysql2", "~> 0.3"
gem "nested_form", "~> 0.3.2"
gem 'newrelic_rpm', '~> 8.16'
gem "nokogiri", ">= 1.10.10"
gem "omniauth", "~> 1.4.2"
gem "omniauth-oauth2", "1.3"
gem 'protected_attributes'
gem "rack-cors", "~> 1.0.3", {:require => 'rack/cors'}
gem "rack-environmental"#, "~> 1.3"
gem 'rack-secure_samesite_cookies', {:git => 'https://github.com/concord-consortium/secure-samesite-cookies.git', :tag => 'v1.0.2'}
gem 'rake', '~> 13.2', '>= 13.2.1'
gem "ribbons-rails", "~> 0.0", {:git=>"https://github.com/concord-consortium/ribbons-rails.git"}
gem "safe_yaml", "~> 1.0.5"
gem "spreadsheet", "~> 1.3.1"
# # gem "sqlite3", "~> 1.3"
# # gem "test-unit", "~> 3.0"
gem "tinymce-rails", '~> 4.9.11.1'
gem "useragent", "~> 0.16.10"
gem "uuidtools", "~> 2.2"
gem "will_paginate", "~> 4.0.1"
