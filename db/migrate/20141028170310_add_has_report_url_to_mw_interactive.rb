class AddHasReportUrlToMwInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :has_report_url, :boolean, default: false
  end
end
