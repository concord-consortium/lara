# This file is used by Rack-based servers to start the application.
require 'shutterbug'
require ::File.expand_path('../config/environment',  __FILE__)


use Shutterbug::Rackapp do |config|
  config.path_prefix = "/shutterbug"
  config.resource_dir = File.expand_path('../public/snapshots',  __FILE__)
end

run LightweightStandalone::Application
