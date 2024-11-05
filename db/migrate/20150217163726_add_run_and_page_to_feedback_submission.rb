class AddRunAndPageToFeedbackSubmission < ActiveRecord::Migration[5.1]
  def change
    add_column :c_rater_feedback_submissions, :interactive_page_id, :integer
    add_column :c_rater_feedback_submissions, :run_id, :integer
    add_index :c_rater_feedback_submissions, [:interactive_page_id, :run_id], name: 'c_rater_fed_submission_page_run_idx'
  end
end
