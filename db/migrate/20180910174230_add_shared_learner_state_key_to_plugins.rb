class AddSharedLearnerStateKeyToPlugins < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins, :shared_learner_state_key, :string
  end
end
