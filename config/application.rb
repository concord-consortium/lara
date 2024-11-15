require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative '../lib/middleware/inject_origin_header_middleware'
require_relative '../lib/rack/response_logger'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module LightweightStandalone
  # TODO: This module name is obsolete.
  class Application < Rails::Application
    config.rails_lts_options = { default: :compatible }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras #{config.root}/lib #{config.root}/services)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.enforce_available_locales = false
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.fallbacks = true
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Configuration for rack-environmental middleware, see https://github.com/techiferous/rack-environmental
    config.middleware.use Rack::Environmental,
                            delayed_job: { url: /delayed_job/,
                                              style: :none},
                            staging: { url: /staging\..+$/,
                                              color: "blueviolet" },
                            test: { url: /jasmine/,
                                              style: :none },
                            development: { url: /^localhost.+$/,
                                              color: "red"        }
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :post, :put, :options]
        resource '/image-proxy', headers: :any, methods: [:get, :options]
      end
    end

    # Force Rack::Cors to always return Access-Control-Allow-Origin by injecting Origin header if it's missing.
    # It's useful for image-proxy and image caching.
    config.middleware.insert_before Rack::Cors, InjectOriginHeaderMiddleware

    # Add a middlewere to log more info about the response
    config.middleware.insert_before 0, Rack::ResponseLogger

    # do not initialize on precompile so that the Dockerfile can run the precompile
    config.assets.initialize_on_precompile = false

    # Set TinyMCE asset compilation method.
    config.tinymce.install = :copy

    config.action_dispatch.use_authenticated_cookie_encryption = true
  end
end

# Mute warnings
SafeYAML::OPTIONS[:default_mode] = :safe
