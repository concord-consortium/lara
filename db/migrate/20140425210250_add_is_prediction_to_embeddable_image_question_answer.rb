class AddIsPredictionToEmbeddableImageQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :embeddable_image_question_answers, :is_prediction, :boolean, :default => false
  end
end
