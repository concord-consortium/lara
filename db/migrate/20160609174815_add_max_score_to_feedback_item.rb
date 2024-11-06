class AddMaxScoreToFeedbackItem < ActiveRecord::Migration
  def change
    add_column :embeddable_feedback_items, :max_score, :integer
    add_column :c_rater_feedback_items,    :max_score, :integer
  end
end
