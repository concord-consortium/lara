class AddIsLockedToActivity < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :is_locked, :boolean, :default => false
  end
end
