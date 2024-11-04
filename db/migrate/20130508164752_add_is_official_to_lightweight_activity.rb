class AddIsOfficialToLightweightActivity < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :is_official, :boolean, default: false
  end
end
