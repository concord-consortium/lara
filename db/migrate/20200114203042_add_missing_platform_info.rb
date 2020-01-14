class AddMissingPlatformInfo < ActiveRecord::Migration
  def up
    runs = Run.joins(:sequence_run).where('runs.platform_id IS NULL AND sequence_runs.platform_id IS NOT NULL').pluck(:id)
    puts "Found #{runs.count} runs with missing platform info"
    runs.each do |run_id|
      run = Run.find(run_id)
      run.update_platform_info(run.sequence_run.attributes)
    end
  end

  def down
  end
end
