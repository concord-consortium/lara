class AddIsAuthorToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_author, :boolean, default: false
  end
end
