class AddSectionToPageItems < ActiveRecord::Migration
  def change
    add_column :page_items, :section, :string
  end
end
