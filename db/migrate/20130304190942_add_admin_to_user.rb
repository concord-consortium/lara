class AddAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, :default => false
  end
end
