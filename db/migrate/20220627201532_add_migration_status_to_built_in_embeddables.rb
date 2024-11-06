class AddMigrationStatusToBuiltInEmbeddables < ActiveRecord::Migration
  def change
    add_column :embeddable_image_questions, :migration_status, :string, default: 'not migrated'
    add_column :embeddable_multiple_choices, :migration_status, :string, default: 'not migrated'
    add_column :embeddable_open_responses, :migration_status, :string, default: 'not migrated'
    add_column :image_interactives, :migration_status, :string, default: 'not migrated'  
    add_column :video_interactives, :migration_status, :string, default: 'not migrated'
  end
end
