class RemoveMaxScoreFromFeedbackItem < ActiveRecord::Migration
  def up
    remove_column :embeddable_feedback_items, :max_score
    remove_column :c_rater_feedback_items, :max_score
  end

  def down
    add_column :embeddable_feedback_items, :max_score, :integer
    add_column :c_rater_feedback_items, :max_score, :integer
  end
end
