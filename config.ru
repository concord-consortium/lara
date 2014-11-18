# This file is used by Rack-based servers to start the application.
require 'shutterbug'
require ::File.expand_path('../config/environment',  __FILE__)


use Shutterbug::Rackapp do |config|
  config.path_prefix = "/shutterbug"
  # use heroku app for now. Uncomment to use local file server.
  config.uri_prefix  = "http://shutterbug.herokuapp.com/"
  # or a locally hosted server for debugging …
  # config.uri_prefix = "http://localhost:5000"
  # config.resource_dir = File.expand_path('../public/snapshots',  __FILE__)
end

run LightweightStandalone::Application
DelayedJobWeb.enable :sessions