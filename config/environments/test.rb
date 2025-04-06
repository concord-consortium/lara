
# configure testing auth portals...
ENV['CONCORD_CONFIGURED_PORTALS']   = "PORTAL"
ENV['CONCORD_PORTAL_URL']           = "http://foo.org"
ENV['CONCORD_PORTAL_CLIENT_ID']     = "localhost"
ENV['CONCORD_PORTAL_CLIENT_SECRET'] = "secret"
ENV['SECRET_TOKEN']                 = "111111111111111111111111111111111111111111111111111111111111"
ENV['LOGGER_URI']                   = "//log.com/api/logs"
ENV['LABBOOK_PROVIDER_URL']         = "https://labbook.test.com"
ENV['ACTIVITY_PLAYER_URL']          = "https://activity-player.concord.org/branch/master"

LightweightStandalone::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Eager loads all registered config.eager_load_namespaces. This includes
  # your application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = true  # normally false unless you use a tool that preloads your test environment

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }

  config.assets.compile = true
  config.assets.debug = false
  config.assets.precompile += %w(runtime.js)

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Execute tests in random order
  config.active_support.test_order = :order

  config.active_record.use_yaml_unsafe_load = true
  config.active_record.belongs_to_required_by_default = false
  config.action_controller.per_form_csrf_tokens = false
  config.action_controller.forgery_protection_origin_check = false
  config.ssl_options = { hsts: { subdomains: false } }

end
