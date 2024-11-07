class AddLearnerUrlToInteractiveRunState < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_run_states, :learner_url, :text
  end
end
