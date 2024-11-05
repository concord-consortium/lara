class AddIsDirtyToInteractiveRunState < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_run_states, :is_dirty, :boolean, :default => false
  end
end
