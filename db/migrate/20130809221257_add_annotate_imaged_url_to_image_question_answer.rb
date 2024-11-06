class AddAnnotateImagedUrlToImageQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :embeddable_image_question_answers, :annotated_image_url, :string
  end
end
