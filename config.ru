# This file is used by Rack-based servers to start the application.
require 'shutterbug'
require ::File.expand_path('../config/environment',  __FILE__)


use Shutterbug::Rackapp do |config|
  config.path_prefix = "/shutterbug"
  config.uri_prefix  =  ENV['SHUTTERBUG_URI']
end

run LightweightStandalone::Application
DelayedJobWeb.enable :sessions