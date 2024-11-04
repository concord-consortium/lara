class CreateCollaborationRuns < ActiveRecord::Migration
  def up
    create_table :collaboration_runs do |t|
      t.integer :user_id
      t.string :collaboration_endpoint_url
      t.timestamps
    end
    add_column :runs, :collaboration_run_id, :integer

    add_index :collaboration_runs, [:collaboration_endpoint_url], name: 'collaboration_runs_endpoint_idx'
    add_index :runs, [:collaboration_run_id], name: 'runs_collaboration_idx'
    # Rename index, as its previous name is too long and causes errors during this migration rollback.
    remove_index :runs, [:user_id, :remote_id, :remote_endpoint]
    add_index :runs, [:user_id, :remote_id, :remote_endpoint], name: 'runs_user_remote_endpt_idx'
  end

  def down
    drop_table :collaboration_runs
    remove_column :runs, :collaboration_run_id

    # Use default index name again. Problems were in the line above, some temp index created during column
    # removal had name longer than 64 chars.
    remove_index :runs, name: 'runs_user_remote_endpt_idx'
    add_index :runs, [:user_id, :remote_id, :remote_endpoint]
  end
end
