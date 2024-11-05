class AddAnnotateImagedUrlToImageQuestionAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_question_answers, :annotated_image_url, :string
  end
end
