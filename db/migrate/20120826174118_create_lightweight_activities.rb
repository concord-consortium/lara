class CreateLightweightActivities < ActiveRecord::Migration
  def change
    create_table :lightweight_activities do |t|
      t.string :name
      t.integer :user_id
      t.string :publication_status

      t.timestamps
    end

    add_index :lightweight_activities, :user_id, :name => 'lightweight_activities_user_idx'
    add_index :lightweight_activities, :publication_status, :name => 'lightweight_activities_publication_status_idx'
  end
end
