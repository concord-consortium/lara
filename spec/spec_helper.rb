# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'webmock/rspec'

# Javascript testing with PhantomJS
require 'capybara/rspec'
require 'capybara/poltergeist'

# https://github.com/dtao/safe_yaml/issues/10
SafeYAML::OPTIONS[:deserialize_symbols] = true

Capybara.javascript_driver = :poltergeist

# this is necessary so shutterbug is correctly initialized in the app that is being tested by Capybara
# otherwise Capybara or poltergeist will fail not being able to load shutterbug.js
Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

# this fixes loading of assets by save_and_open_page pages. You'll need to have
# a server running at this location that serves the assets required by the page.
# this isn't documented other than the discussion in this pull request:
# https://github.com/jnicklas/capybara/pull/958
Capybara.asset_host = 'http://localhost:3000'

OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:concord_portal, {
  :uid      => 'fake_concord_user',
  :provider => 'concord_portal',
  :credentials => {:token => 'token'} }
)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Include Devise helpers
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view

  # this really doesn't seem like it should be necessary, so I wonder about
  # wether the require capybara/rspec is working or needed above
  config.include Rails.application.routes.url_helpers, :type => :feature

  Devise.stretches = 1
  WebMock.disable_net_connect!(:allow_localhost => true)
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection