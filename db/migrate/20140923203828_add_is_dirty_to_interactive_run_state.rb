class AddIsDirtyToInteractiveRunState < ActiveRecord::Migration
  def change
    add_column :interactive_run_states, :is_dirty, :boolean, default: false
  end
end
