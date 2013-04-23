class AddRemoteKeyStringToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :remote_id, :string
  end
end
