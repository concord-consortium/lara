class AddRemoteEndpointToRun < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :remote_endpoint, :string
  end
end
