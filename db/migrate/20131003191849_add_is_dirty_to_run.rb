class AddIsDirtyToRun < ActiveRecord::Migration
  def change
    add_column :runs, :is_dirty, :boolean, :default => false
  end
end
