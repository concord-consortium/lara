class AddStateToPluginLearnerStates < ActiveRecord::Migration[5.1]
  def change
    add_column :plugin_learner_states, :state, :text
  end
end
