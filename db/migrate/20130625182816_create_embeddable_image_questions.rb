class CreateEmbeddableImageQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_image_questions do |t|
      t.string :name
      t.text :prompt

      t.timestamps
    end
  end
end
