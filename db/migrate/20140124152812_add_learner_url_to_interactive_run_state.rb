class AddLearnerUrlToInteractiveRunState < ActiveRecord::Migration
  def change
    add_column :interactive_run_states, :learner_url, :text
  end
end
