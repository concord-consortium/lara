class AddSharedLearnerStateKeyToPlugins < ActiveRecord::Migration
  def change
    add_column :plugins, :shared_learner_state_key, :string
  end
end
