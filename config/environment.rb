# Load the rails application
require File.expand_path('../application', __FILE__)

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
if File.exist?(app_environment_variables)
  load(app_environment_variables)
else
  # TODO: Should we just die here otherwise?
  puts "please create the file #{app_environment_variables}, or set ENV"
end

Rails.application.configure do
  config.active_support.to_time_preserves_timezone = :zone
end

# Initialize the rails application
LightweightStandalone::Application.initialize!
