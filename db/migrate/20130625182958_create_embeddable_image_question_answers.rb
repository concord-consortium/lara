class CreateEmbeddableImageQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :embeddable_image_question_answers do |t|
      t.references :run
      t.text :answer_text
      t.string :image_url
      t.integer :image_question_id
      t.timestamps
    end
    add_index :embeddable_image_question_answers, :run_id
  end
end
