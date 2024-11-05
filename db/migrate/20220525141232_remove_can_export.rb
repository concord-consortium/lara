class RemoveCanExport < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :can_export
  end

  def down
    add_column :users, :can_export, :boolean
  end
end
