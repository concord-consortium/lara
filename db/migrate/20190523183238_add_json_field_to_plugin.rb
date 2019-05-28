class AddJsonFieldToPlugin < ActiveRecord::Migration
  def change
    add_column :approved_scripts, :json_url, :string
  end
end
