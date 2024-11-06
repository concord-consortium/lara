class AddCanExportToUser < ActiveRecord::Migration
  def change
    add_column :users, :can_export, :boolean, default: false
  end
end
