class AddIndexToFeedbackSubmissions < ActiveRecord::Migration[5.1]
  def up
    add_index :c_rater_feedback_submissions, [:interactive_page_id, :run_id, :created_at], name: 'c_rater_fed_submission_page_run_created_idx'
    remove_index :c_rater_feedback_submissions, name: 'c_rater_fed_submission_page_run_idx'
  end

  def down
    add_index :c_rater_feedback_submissions, [:interactive_page_id, :run_id], name: 'c_rater_fed_submission_page_run_idx'
    remove_index :c_rater_feedback_submissions, name: 'c_rater_fed_submission_page_run_created_idx'
  end
end
