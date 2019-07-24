class RemoveExternalReportUrlFromLightWeightActivity < ActiveRecord::Migration
  # Removes columns added in AddExternalReportUrlToLightweightActivity
  # 20160722195644_add_external_report_url_to_lightweight_activity.rb

  def up
    remove_column :lightweight_activities, :external_report_url
    remove_column :sequences, :external_report_url
  end

  def down
    add_column :lightweight_activities, :external_report_url, :text
    add_column :sequences, :external_report_url, :text
  end
end
