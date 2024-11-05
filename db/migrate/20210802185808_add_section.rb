
class AddSection < ActiveRecord::Migration[5.1]
  def up
    create_table :sections do |t|
      t.string :title
      t.boolean :show
      t.string :layout
      t.integer :position
      t.references :interactive_page
      t.boolean :can_collapse_small
      t.timestamps
    end
    change_table :page_items do |t|
      t.references :section
      t.string :column
      t.integer :section_position
    end
    rename_column :page_items, :section, :old_section
  end

  def down
    drop_table :sections
    remove_column :page_items, :section_id
    remove_column :page_items, :column
    remove_column :page_items, :section_position
    rename_column :page_items, :old_section, :section
  end
end
