class AddBaseSubmissionToFeedbackSubmissions < ActiveRecord::Migration
  def change
    add_column :c_rater_feedback_submissions, :base_submission_id, :integer
    add_index :c_rater_feedback_submissions, :base_submission_id, name: 'feedback_submissions_base_sub_id_idx'
  end
end
