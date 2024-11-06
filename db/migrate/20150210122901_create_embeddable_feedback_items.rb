class CreateEmbeddableFeedbackItems < ActiveRecord::Migration
  def change
    create_table :embeddable_feedback_items do |t|
      t.references :answer, polymorphic: true
      t.integer :score
      t.text :feedback_text
      t.text :answer_text
      t.timestamps
    end
    add_index :embeddable_feedback_items, [:answer_id, :answer_type]
  end
end
