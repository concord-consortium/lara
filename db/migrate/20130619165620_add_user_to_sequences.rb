class AddUserToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :user_id, :integer
  end
end
