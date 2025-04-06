source "https://rubygems.org"
  gem 'actionmailer', '~> 8.0.1', require: false
  gem 'actionpack', '~> 8.0.1', require: false
  gem 'activemodel', '~> 8.0.1', require: false
  gem 'activerecord', '~> 8.0.1', require: false
  gem 'activesupport', '~> 8.0.1', require: false
  gem 'rails', '~> 8.0.1'
  gem 'railties', '~> 8.0.1', require: false

group :production do
  gem "unicorn"
end

# group :assets do
  gem "coffee-rails", '~> 4.2', '>= 4.2.2'
  gem "sass-rails", "= 5.0.8"
  gem "sassc", "~> 2.1.0"
  gem "terser"
# end

source 'https://rails-assets.org' do
  gem 'rails-assets-drawing-tool', '1.3.2'
  gem 'rails-assets-modulejs', '1.6.0'
end

group :development do
  gem "better_errors", "~> 2.0.0", ">= 2.0.0"
  gem "web-console", "~> 3.7"
end

group :test do
  gem "factory_bot_rails"
  gem 'simplecov', require: false
  gem "webmock", "~> 3.8.3", "= 3.8.3"
end

group :test, :development do
  gem "capybara", "~> 2.18"
  gem "faker"
  gem "jasmine", "~> 2.99.0"
  gem "jasmine-jquery-rails", "~> 2.0", ">= 2.0.3"
  gem "launchy", "~> 2.5", ">= 2.5.2"
  gem "poltergeist", "~> 1.18", ">= 1.18.1"
  gem "rspec-activemodel-mocks", '~> 1.2', '>= 1.2.1'
  gem "rspec-rails", '~> 6.0'
  gem "spring", "~> 3.0"
  gem "spring-commands-rspec", "~> 1.0", ">= 1.0.4"
  gem "test-unit", "~> 3.6", ">= 3.6.2"
  gem "timecop", "~> 0.9", ">= 0.9.10"
  gem 'rails-controller-testing'
end

gem "acts_as_list"
gem 'aws-sdk', '~> 3'
gem "aws-ses", "0.7.1", git: "https://github.com/zebitex/aws-ses.git", ref: "78-sigv4-problem"
gem "bootsnap"
gem "cancancan"
gem "chosen-rails", "~> 1.10"
gem 'concurrent-ruby', '= 1.3.4'
gem "daemons", "~> 1.4", ">= 1.4.1"
gem "default_value_for"
gem "delayed_job_active_record", '~> 4.1', '>= 4.1.10'
gem "delayed_job_web", '~> 1.4', '>= 1.4.4'
gem "devise", '~> 4.4', '>= 4.4.0'
gem "dynamic_form", "= 1.2"
gem "exception_notification"
gem "ffi", "~> 1.17"
gem "font-awesome-rails", '~> 4.7', '>= 4.7.0.8'
gem "gon", "~> 6.4.0"
gem "haml", "~> 5.2"
gem "highline", "~> 1.7.3"
gem "httparty", ">= 0.21"
gem "i18n", ">= 1.8"
gem "jquery-rails", '~> 4.1', '>= 4.1.0'
gem "jquery-ui-rails", '~> 4.2.1'
gem "loofah", "= 2.24.0"
gem "multi_json", "~> 1.15"
gem "mysql2", "~> 0.5"
gem "nested_form", "~> 0.3.2"
gem 'newrelic_rpm'
gem "nokogiri"
gem "omniauth", "= 1.4.2"
gem "omniauth-oauth2", "1.3"
gem "rack-cors", "~> 1.0.3", {require: 'rack/cors'}
gem "rack-environmental"
gem 'rack-secure_samesite_cookies', {git: 'https://github.com/concord-consortium/secure-samesite-cookies.git', tag: 'v1.0.2'}
gem 'rake', '~> 13.2', '>= 13.2.1'
gem "responders", "~> 3.1.1"
gem "ribbons-rails", "~> 0.0", {git: "https://github.com/concord-consortium/ribbons-rails.git"}
gem "spreadsheet", "~> 1.1.2", "= 1.1.2"
gem "tinymce-rails", '~> 4.9.4', "= 4.9.4"
gem "useragent", "~> 0.16.10"
gem "uuidtools", "~> 2.1.5", "= 2.1.5"
gem "will_paginate", "~> 4.0.1"

# The gems below were determined to no longer be needed after the upgrade to Rails 5.
# For now we're leaving them here for reference just in case we need to add them back
# in the future.

# # Previously in the :development group
# gem "binding_of_caller", "~> 0.7"
# gem "brakeman", "~> 2.4", {:require=>false}
# gem 'bullet', "= 6.1.5"
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

# # Previously in the :test, :development group
# gem "ci_reporter", "~> 1.9.2"
# gem "pry"
# gem 'pry-byebug'
# gem "rb-fsevent", "~> 0.9"

# # Previously not grouped
# gem "safe_yaml", "~> 1.0.5"
# gem "sprockets", "~> 3.7", "= 3.7.5"
# gem "sqlite3", "~> 1.3"
# gem "test-unit", "~> 3.0"
# gem "turbo-sprockets-rails4", "~> 1.2.5"
