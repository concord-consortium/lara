class AddExternalReportUrlToLightweightActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :external_report_url, :text
    add_column :sequences, :external_report_url, :text
  end
end
