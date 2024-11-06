class AddStateToPluginLearnerStates < ActiveRecord::Migration
  def change
    add_column :plugin_learner_states, :state, :text
  end
end
