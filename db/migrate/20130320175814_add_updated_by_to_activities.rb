class AddUpdatedByToActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :changed_by_id, :integer
  end
end
