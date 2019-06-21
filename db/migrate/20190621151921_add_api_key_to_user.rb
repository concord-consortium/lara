class AddApiKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :text
  end
end
