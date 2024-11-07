class AddFontSizeSetting < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :font_size, :string, default: "normal"
    add_column :sequences, :font_size, :string, default: "normal"
  end
end
