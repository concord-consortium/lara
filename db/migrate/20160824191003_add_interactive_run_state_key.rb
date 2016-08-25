class AddInteractiveRunStateKey < ActiveRecord::Migration
  def change
    add_column :interactive_run_states, :key, :string

    add_index :interactive_run_states, :key, :name => 'interactive_run_states_key_idx'

    # create random key for the existing run states
    InteractiveRunState.all.each do |interactive_run_state|
      interactive_run_state.key = InteractiveRunState.generate_key
      interactive_run_state.save
    end
  end
end
