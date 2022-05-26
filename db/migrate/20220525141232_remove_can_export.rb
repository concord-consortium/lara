class RemoveCanExport < ActiveRecord::Migration
  def up
    remove_column :users, :can_export
  end

  def down
    add_column :users, :can_export, :boolean
  end
end
