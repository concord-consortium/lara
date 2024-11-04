class ActivitiesSequenceAllowNullPosition < ActiveRecord::Migration
  def up
    change_column(:lightweight_activities_sequences, :position, :integer, null: true)
  end

  def down
    change_column(:lightweight_activities_sequences, :position, :integer, null: false)
  end
end
