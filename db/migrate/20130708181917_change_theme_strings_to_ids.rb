class ChangeThemeStringsToIds < ActiveRecord::Migration[5.1]
  def up
    remove_column :lightweight_activities, :theme
    add_column :lightweight_activities, :theme_id, :integer, null: true
    remove_column :sequences, :theme
    add_column :sequences, :theme_id, :integer, null: true
  end

  def down
    remove_column :lightweight_activities, :theme_id
    add_column :lightweight_activities, :theme, :string, null: true
    remove_column :sequences, :theme_id
    add_column :sequences, :theme, :string, null: true
  end
end
