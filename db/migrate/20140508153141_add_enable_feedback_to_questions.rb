class AddEnableFeedbackToQuestions < ActiveRecord::Migration
  def change
    add_column :embeddable_open_responses, :give_prediction_feedback, :boolean, :default => false
    add_column :embeddable_multiple_choices, :give_prediction_feedback, :boolean, :default => false
    add_column :embeddable_image_questions, :give_prediction_feedback, :boolean, :default => false

    add_column :embeddable_open_responses, :prediction_feedback, :text
    add_column :embeddable_multiple_choices, :prediction_feedback, :text
    add_column :embeddable_image_questions, :prediction_feedback, :text
  end
end
