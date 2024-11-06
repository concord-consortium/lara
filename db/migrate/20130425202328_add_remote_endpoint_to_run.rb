class AddRemoteEndpointToRun < ActiveRecord::Migration
  def change
    add_column :runs, :remote_endpoint, :string
  end
end
