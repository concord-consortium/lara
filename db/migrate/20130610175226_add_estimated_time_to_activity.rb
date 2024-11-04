class AddEstimatedTimeToActivity < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :time_to_complete, :integer, null: true
  end
end
