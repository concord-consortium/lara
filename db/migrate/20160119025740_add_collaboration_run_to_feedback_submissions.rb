class AddCollaborationRunToFeedbackSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :c_rater_feedback_submissions, :collaboration_run_id, :integer
  end
end
