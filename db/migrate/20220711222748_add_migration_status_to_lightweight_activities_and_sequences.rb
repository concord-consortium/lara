class AddMigrationStatusToLightweightActivitiesAndSequences < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :migration_status, :string, default: 'not_migrated'
    add_column :sequences, :migration_status, :string, default: 'not_migrated'
  end
end
