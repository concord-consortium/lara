class AddHasReportUrlToMwInteractive < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :has_report_url, :boolean, default: false
  end
end
