require_dependency Rails.root.join("lib/delayed/plugins/tagged_logging").to_s

# Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 1
# Delayed::Worker.max_attempts = 25
# Delayed::Worker.max_run_time = 4.hours

Delayed::Worker.plugins << Delayed::Plugins::TaggedLogging

Delayed::Worker.delay_jobs = Rails.env.production? || !!ENV['DELAYEDJOB']
