class AddActivityIdToRun < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :key,         :string
    add_column :runs, :activity_id, :integer
  end
end
