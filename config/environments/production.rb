require 'uglifier'

LightweightStandalone::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  if ENV['RAILS_STDOUT_LOGGING'].present?
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += %w(runtime.js respond.js modernizr.min.js)
  # Themes:
  config.assets.precompile += %w(
  runtime.css theme-mw.css theme-has-ngs.css theme-has-ngs-atmosphere.css
  theme-has-ngs-climate.css theme-has-ngs-hydrofracking.css theme-has-ngs-landmanagement.css
  theme-has-ngs-water.css theme-rites.css print-summary.css theme-interactions-electrostatics.css
  theme-interactions.css theme-inquiryspace.css theme-itsi.css theme-itsi-survey.css theme-has-astro.css
  theme-has-astro-dark.css theme-ngss-assessment.css theme-building-models.css theme-geode-himalayas.css
  theme-ipums-terra.css theme-data-games.css theme-precipitating-change.css theme-geniventure.css
  theme-connectedbio.css theme-geohazard.css theme-geocode.css theme-rmath.css theme-waters.css
  theme-geohazard-wildfire.css theme-geohazard-flood.css theme-waters-2.css theme-geocode-seismic.css)
  # CSS file used by TinyMCE iframe:
  config.assets.precompile += %w(tinymce-content.css)
  # Icon SVGs used by activity page nav menu:
  config.assets.precompile += %w(
  icons/page-nav/*)
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.default_url_options = { :host => 'authoring.concord.org' }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :ses
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
