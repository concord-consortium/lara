class CreateCRaterFeedbackSubmission < ActiveRecord::Migration[5.1]
  def change
    create_table :c_rater_feedback_submissions do |t|
      t.integer :usefulness_score
      t.timestamps
    end
  end
end
