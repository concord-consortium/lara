class AddIndexesToSections < ActiveRecord::Migration
  def change
    add_index :sections, [:interactive_page_id, :position]
    add_index :page_items, [:section_id, :position]
    remove_index :page_items, :interactive_page_id
  end
end
