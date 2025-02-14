if ENV['COVERAGE_REPORT']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'rspec/active_model/mocks'

# This breaks on travis, but works for me locally
# require 'ruby-debug'

# Javascript testing with PhantomJS
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
# Capybars default wait of 2s is too slow for some of our tests in travis
Capybara.default_max_wait_time = 5

# this is necessary so shutterbug is correctly initialized in the app that is being tested by Capybara
# otherwise Capybara or poltergeist will fail not being able to load shutterbug.js
Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

# this fixes loading of assets by save_and_open_page pages. You'll need to have
# a server running at this location that serves the assets required by the page.
# this isn't documented other than the discussion in this pull request:
# https://github.com/jnicklas/capybara/pull/958
Capybara.asset_host = 'http://localhost:3000'

OmniAuth.config.test_mode = true

def add_fake_authorization(strat_name)
  url       = "http://#{strat_name}.org/"
  client_id = strat_name
  secret    = "secret"
  strat = Concord::AuthPortal.add(strat_name,url,client_id,secret)
  OmniAuth.config.add_mock(strat.strategy_name, {
    uid: 'fake_concord_user',
    provider: strat.strategy_name,
    credentials: {token: 'token'} }
  )
end

add_fake_authorization('concord.portal')
add_fake_authorization('portal')

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
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  # # this really doesn't seem like it should be necessary, so I wonder about
  # # wether the require capybara/rspec is working or needed above
  # config.include Rails.application.routes.url_helpers, type: :feature

  Devise.stretches = 1
  WebMock.disable_net_connect!(allow_localhost: true)

  # on Scott's OS X 10.6 machine, phantom needs to visit a simple page before
  # it works reliably
  config.before(:each, js: true) {
    ENV['RUNNING_JS_TEST'] = 'true'
    visit '/404.html'
  }

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods

  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end
  config.before(:each) do
    stub_temporary_protocol_routes
    clean_env_vars
  end

  # include the Haml helper module
  config.include Haml::Helpers, type: :helper
end

class ApplicationRecord
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ApplicationRecord.shared_connection = ApplicationRecord.connection

def wait_for_ajax
  counter = 0
  while page.evaluate_script("$.active").to_i > 0
    counter += 1
    sleep(0.1)
    raise "AJAX request took longer than 5 seconds." if counter >= 50
  end
end

def stub_temporary_protocol_routes
  # These requests are made when attempting to post to a portal.
  # This code will be removed when versioned learner data is widely deployed to portals.
  stub_request(:any, /.*\/#{PortalSender::Protocol::VersionRoutePrefix}\/.*/)
  .to_return(status: [500, "Internal Server Error"])
end

# some ENV vars set on dev machines should be ignored for tests:
def  clean_env_vars
  envs = %w(
    REPORT_SERVICE_SELF_URL REPORT_SERVICE_URL REPORT_SERVICE_TOKEN
  )
  envs.each { |e| ENV.delete(e) }
end

def add_linked_interactive(primary, secondary, label = nil)
  FactoryBot.create(:linked_page_item, {primary: primary.page_item, secondary: secondary.page_item, label: label})
end