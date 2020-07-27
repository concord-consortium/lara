class AddLinkedPageItems < ActiveRecord::Migration
  def change
    create_table :linked_page_items do |t|
      t.integer :primary_id
      t.integer :secondary_id
      t.string  :label

      t.timestamps
    end

    add_index :linked_page_items, [:primary_id, :secondary_id], :unique => true, :name => 'index_linked_page_items_unique'
    add_index :linked_page_items, :primary_id, :name => 'index_linked_page_items_primary'
    add_index :linked_page_items, :secondary_id, :name => 'index_linked_page_items_secondary'
  end
end
