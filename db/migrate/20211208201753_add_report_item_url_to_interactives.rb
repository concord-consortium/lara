class AddReportItemUrlToInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :library_interactives, :report_item_url, :text
    add_column :mw_interactives, :report_item_url, :text
  end
end
