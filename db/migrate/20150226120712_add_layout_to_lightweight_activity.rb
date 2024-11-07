class AddLayoutToLightweightActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :layout, :integer, default: 0
  end
end
