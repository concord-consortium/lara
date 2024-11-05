class AddAnnotationToEmbeddableImageQuestionAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_question_answers, :annotation, :text
  end
end
