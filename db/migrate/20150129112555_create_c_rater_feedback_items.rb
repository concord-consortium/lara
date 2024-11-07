class CreateCRaterFeedbackItems < ActiveRecord::Migration[5.1]
  def change
    create_table :c_rater_feedback_items do |t|
      t.text :answer_text
      t.references :answer, polymorphic: true
      t.integer :item_id
      t.string :status
      t.integer :score
      t.text :feedback_text
      t.text :response_info

      t.timestamps
    end
    add_index :c_rater_feedback_items, [:answer_id, :answer_type]
  end
end
