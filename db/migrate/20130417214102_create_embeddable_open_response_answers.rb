class CreateEmbeddableOpenResponseAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_open_response_answers do |t|
      t.text :answer_text
      t.integer :run_id
      t.integer :open_response_id

      t.timestamps
    end
  end
end
