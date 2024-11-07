class AddUserToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :user_id, :integer
  end
end
