class AddIsLockedToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :is_locked, :boolean, :default => false
  end
end
