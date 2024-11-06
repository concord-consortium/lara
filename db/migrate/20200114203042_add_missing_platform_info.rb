class AddMissingPlatformInfo < ActiveRecord::Migration
  def up
    runs = Run.joins(:sequence_run).where('runs.platform_id IS NULL AND sequence_runs.platform_id IS NOT NULL').pluck(:id)
    puts "Found #{runs.count} runs with missing platform info"
    runs.each do |run_id|
      run = Run.find(run_id)
      run.update_platform_info(run.sequence_run.attributes)
      # Sending run to firestore
      # check that the local environment has
      # ENV["REPORT_SERVICE_SELF_URL"]
      # ENV["REPORT_SERVICE_URL"]
      # ENV["REPORT_SERVICE_TOKEN"]
      sender = ReportService::RunSender.new(run, { send_all_answers: true })
      result = sender.send
      if !result || !result["success"]
        puts "Failed to send Run: #{run.id}"
      end
    end
  end

  def down
  end
end
