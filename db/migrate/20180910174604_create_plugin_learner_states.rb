class CreatePluginLearnerStates < ActiveRecord::Migration[5.1]
  def change
    create_table :plugin_learner_states do |t|
      t.integer :plugin_id
      t.integer :user_id
      t.integer :run_id
      t.string  :shared_learner_state_key
      t.timestamps
    end

    add_index :plugin_learner_states, [:plugin_id, :run_id], name: 'plugin_run__states'
    add_index :plugin_learner_states, [:shared_learner_state_key, :run_id], name: 'shared_run_plugin_states'
    add_index :plugin_learner_states, [:shared_learner_state_key, :user_id], name: 'shared_user_plugin_states'
  end

end
