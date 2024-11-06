class AddFeedbackSubmissionToFeedbackItem < ActiveRecord::Migration
  def change
    add_column :embeddable_feedback_items, :feedback_submission_id, :integer
    add_column :embeddable_feedback_items, :feedback_submission_type, :string
    add_index :embeddable_feedback_items, [:feedback_submission_id, :feedback_submission_type], name: 'e_feed_item_submission_idx'

    add_column :c_rater_feedback_items, :feedback_submission_id, :integer
    add_column :c_rater_feedback_items, :feedback_submission_type, :string
    add_index :c_rater_feedback_items, [:feedback_submission_id, :feedback_submission_type], name: 'c_rater_feed_item_submission_idx'
  end
end
