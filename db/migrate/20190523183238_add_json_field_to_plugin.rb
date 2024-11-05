class AddJsonFieldToPlugin < ActiveRecord::Migration[5.1]
  def change
    add_column :approved_scripts, :json_url, :string
  end
end
