class CreateEmbeddableMultipleChoiceAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_multiple_choice_answers do |t|
      t.text :answer_ids
      t.text :answer_texts
      t.integer :run_id
      t.integer :multiple_choice_id
      t.timestamps
    end
  end
end
