class AddFixedWidthLayouts < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :fixed_width_layout, :string, default: "1100px"
    add_column :sequences, :fixed_width_layout, :string, default: "1100px"
  end
end
