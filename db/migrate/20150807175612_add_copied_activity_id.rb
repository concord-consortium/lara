class AddCopiedActivityId < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :copied_from_id, :integer
  end
end

