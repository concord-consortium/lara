LightweightStandalone::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Eager loads all registered config.eager_load_namespaces. This includes your
  # application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.js_compressor = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.active_record.use_yaml_unsafe_load = true
  config.active_record.belongs_to_required_by_default = false
  config.action_controller.per_form_csrf_tokens = false
  config.action_controller.forgery_protection_origin_check = false
  config.ssl_options = { hsts: { subdomains: false } }

  # include per developer environment files if found (the default is excluded by .gitignore)
  #
  # Here is a sample local-development.rb file to speed up requests
  #
  # LightweightStandalone::Application.configure do
  #   config.assets.debug = false
  #   config.after_initialize do
  #     Bullet.enable = false
  #     Bullet.bullet_logger = false
  #     Bullet.rails_logger = false
  #     Bullet.add_footer = false
  #   end
  # end
  localDevPath = File.expand_path((ENV['LOCAL_DEV_ENVIRONMENT_FILE'] || 'local-development.rb'), File.dirname(__FILE__))
  require(localDevPath) if File.file?(localDevPath)

  if ENV["RAILS_STDOUT_LOGGING"].present?
    # Disable logging to file. It might have performance impact while using Docker for Mac (slow filesystem sync).
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end
end

# Open file links in BetterErrors in sublime text.
# On a mac, you will need to use this tool, or something similar:
# https://github.com/dhoulb/subl
BetterErrors.editor = :subl

# Flush stdout which is used for logging, in some cases docker was not seeing the
# output. There might be a better way to handle this.
$stdout.sync = true
