require 'delayed_job_tagged_logging'
Delayed::Worker.plugins << Delayed::Plugins::TaggedLogging

Delayed::Worker.delay_jobs = Rails.env.production? || !!ENV['DELAYEDJOB']
