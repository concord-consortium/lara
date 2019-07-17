class AddLastReportServiceHashToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :last_report_service_hash, :text
    add_column :lightweight_activities, :last_report_service_hash, :text
  end
end
