class AddIsAuthorToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_author, :boolean, default: false
  end
end
