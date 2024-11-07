class AddFirstAndLastNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :first_name, :string, limit: 100
    add_column :users, :last_name, :string, limit: 100
  end
end
