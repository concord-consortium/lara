class AddFixedWidthLayouts < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :fixed_width_layout, :string, default: "not_enabled"
    add_column :sequences, :fixed_width_layout, :string, default: "not_enabled"
  end
end
