class CreateInteractiveItems < ActiveRecord::Migration
  def change
    create_table :interactive_items do |t|
      t.integer :interactive_page_id
      t.integer :interactive_id
      t.string  :interactive_type
      t.integer :position

      t.timestamps
    end

    add_index :interactive_items, [:interactive_page_id, :position], :name => 'interactive_items_by_page_idx'
    add_index :interactive_items, [:interactive_id, :interactive_type], :name => 'interactive_items_interactive_idx'
  end
end
