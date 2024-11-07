class AddUpdatedByToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :changed_by_id, :integer
  end
end
