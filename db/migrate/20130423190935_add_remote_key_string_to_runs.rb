class AddRemoteKeyStringToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :remote_id, :string
  end
end
