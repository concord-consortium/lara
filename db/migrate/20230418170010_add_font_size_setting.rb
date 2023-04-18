class AddFontSizeSetting < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :font_size, :string, default: "normal"
    add_column :sequences, :font_size, :string, default: "normal"
  end
end
