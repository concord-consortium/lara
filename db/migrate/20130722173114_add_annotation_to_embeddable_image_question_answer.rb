class AddAnnotationToEmbeddableImageQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :embeddable_image_question_answers, :annotation, :text
  end
end
