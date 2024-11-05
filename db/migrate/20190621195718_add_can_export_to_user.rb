class AddCanExportToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :can_export, :boolean, default: false
  end
end
