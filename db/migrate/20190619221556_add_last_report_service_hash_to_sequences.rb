class AddLastReportServiceHashToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :last_report_service_hash, :text
    add_column :lightweight_activities, :last_report_service_hash, :text
  end
end
