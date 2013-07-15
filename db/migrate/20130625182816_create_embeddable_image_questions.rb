class CreateEmbeddableImageQuestions < ActiveRecord::Migration
  def change
    create_table :embeddable_image_questions do |t|
      t.string :name
      t.text :prompt

      t.timestamps
    end
  end
end
