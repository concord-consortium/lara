Delayed::Worker.delay_jobs = Rails.env.production? || !!ENV['DELAYEDJOB']
if Rails.env.development?
  Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
end
