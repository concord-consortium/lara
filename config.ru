# This file is used by Rack-based servers to start the application.
require 'shutterbug'
require ::File.expand_path('../config/environment',  __FILE__)


use Shutterbug::Rackapp do |config|
  config.uri_prefix = "http://shutterbug.herokuapp.com/"
  config.path_prefix = "/shutterbug"
  #config.phantom_bin_path = "/app/vendor/phantomjs/bin/phantomjs"
end

run LightweightStandalone::Application
