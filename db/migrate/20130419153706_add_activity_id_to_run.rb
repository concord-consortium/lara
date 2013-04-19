class AddActivityIdToRun < ActiveRecord::Migration
  def change
    add_column :runs, :key,         :string
    add_column :runs, :activity_id, :integer
  end
end
