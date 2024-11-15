class AddInteractiveRunStateKey < ActiveRecord::Migration[5.1]
  def up
    add_column :interactive_run_states, :key, :string
    add_index :interactive_run_states, :key, name: 'interactive_run_states_key_idx'

    # create random key for the existing run states
    InteractiveRunState.find_each do |interactive_run_state|
      interactive_run_state.key = InteractiveRunState.generate_key
      interactive_run_state.save
    end
  end

  def down
    remove_index :interactive_run_states, name: 'interactive_run_states_key_idx'
    remove_column :interactive_run_states, :key
  end
end
