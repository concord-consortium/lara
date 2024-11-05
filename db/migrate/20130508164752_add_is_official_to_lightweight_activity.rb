class AddIsOfficialToLightweightActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :is_official, :boolean, :default => false
  end
end
