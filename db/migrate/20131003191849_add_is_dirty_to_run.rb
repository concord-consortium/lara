class AddIsDirtyToRun < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :is_dirty, :boolean, :default => false
  end
end
