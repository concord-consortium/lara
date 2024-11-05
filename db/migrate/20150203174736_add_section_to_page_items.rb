class AddSectionToPageItems < ActiveRecord::Migration[5.1]
  def change
    add_column :page_items, :section, :string
  end
end
