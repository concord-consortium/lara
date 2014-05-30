# Whitelist config options for SMTP
CONFIG_OPTIONS = %w(default_options logger smtp_settings sendmail_settings file_settings raise_delivery_errors delivery_method perform_deliveries deliveries)

if File.exists?("#{::Rails.root.to_s}/config/mailer.yml") || ::Rails.env == "test" || ::Rails.env == "cucumber"
  require "action_mailer"
  if ::Rails.env == "test" || ::Rails.env == "cucumber"
    puts "Overriding ActionMailer config and setting test mode"
    ActionMailer::Base.delivery_method = :test
  else
    config_file = Rails.root.join("config", "mailer.yml")
    ActionMailer::Base.smtp_settings = YAML.load_file(config_file)[Rails.env].try(:to_options)
  end
end
