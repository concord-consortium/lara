class RenameSettingsToItemSettings < ActiveRecord::Migration
  def up
    rename_table :c_rater_settings, :c_rater_item_settings
  end

  def down
    rename_table :c_rater_item_settings, :c_rater_settings
  end
end
