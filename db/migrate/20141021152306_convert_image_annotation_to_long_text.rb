class ConvertImageAnnotationToLongText < ActiveRecord::Migration[5.1]
  def up
    change_column :embeddable_image_question_answers, :annotation, :text, limit: 4294967294
  end

  def down
    change_column :embeddable_image_question_answers, :annotation, :text, limit: 65534
  end
end
