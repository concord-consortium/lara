class AddEstimatedTimeToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :time_to_complete, :integer, null: true
  end
end
