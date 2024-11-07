class AddInteractiveIndexToInteractiveRunStates < ActiveRecord::Migration[5.1]
  def change
    add_index :interactive_run_states, [:interactive_id, :interactive_type], name: 'interactive_run_states_interactive_idx'
  end
end
