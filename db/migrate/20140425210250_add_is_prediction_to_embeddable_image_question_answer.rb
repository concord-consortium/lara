class AddIsPredictionToEmbeddableImageQuestionAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_question_answers, :is_prediction, :boolean, :default => false
  end
end
