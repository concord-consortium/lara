class UpdateRunAttributes < ActiveRecord::Migration
  def up
    rename_column :runs, :class_hash, :context_id
    add_column :runs, :platform_id, :string
    add_column :runs, :platform_user_id, :string
    add_column :runs, :resource_link_id, :string

    rename_column :sequence_runs, :class_hash, :context_id
    add_column :sequence_runs, :platform_id, :string
    add_column :sequence_runs, :platform_user_id, :string
    add_column :sequence_runs, :resource_link_id, :string
  end

  def down
    rename_column :runs, :context_id, :class_hash
    remove_column :runs, :platform_id
    remove_column :runs, :platform_user_id
    remove_column :runs, :resource_link_id

    rename_column :sequence_runs, :context_id, :class_hash
    remove_column :sequence_runs, :platform_id
    remove_column :sequence_runs, :platform_user_id
    remove_column :sequence_runs, :resource_link_id
  end
end
