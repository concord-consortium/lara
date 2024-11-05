class CreateLightweightActivitiesSequences < ActiveRecord::Migration[5.1]
  def change
    create_table :lightweight_activities_sequences do |t|
      t.integer :lightweight_activity_id, :default => 1, :null => false
      t.integer :sequence_id, :default => 1, :null => false
      t.integer :position, :default => 1, :null => false

      t.timestamps
    end
  end
end
