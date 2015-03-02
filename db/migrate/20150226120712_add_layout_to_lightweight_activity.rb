class AddLayoutToLightweightActivity < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :layout, :integer, default: 0
  end
end
