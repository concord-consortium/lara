class AddCopiedActivityId < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :copied_from_id, :integer
  end
end

