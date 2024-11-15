class CreateEmbeddableImageQuestionAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_image_question_answers do |t|
      t.references :run
      t.text :answer_text
      t.string :image_url
      t.integer :image_question_id
      t.timestamps
    end
    unless index_exists?(:embeddable_image_question_answers, :run_id)
      add_index :embeddable_image_question_answers, :run_id
    end
  end
end
