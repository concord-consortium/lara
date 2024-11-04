class CreateInteractivePages < ActiveRecord::Migration
  def change
    create_table :interactive_pages do |t|
      t.string  :name
      t.integer :lightweight_activity_id
      t.integer :user_id
      t.integer :position
      t.text    :text

      t.timestamps
    end

    add_index :interactive_pages, :user_id, name: 'interactive_pages_user_idx'
    add_index :interactive_pages, [:lightweight_activity_id, :position], name: 'interactive_pages_by_activity_idx'
  end
end
