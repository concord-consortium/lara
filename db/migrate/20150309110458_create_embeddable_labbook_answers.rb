class CreateEmbeddableLabbookAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_labbook_answers do |t|
      t.integer :run_id
      t.integer :labbook_id
      t.boolean :is_dirty, default: false
      t.timestamps
    end
    add_index :embeddable_labbook_answers, :run_id
    add_index :embeddable_labbook_answers, :labbook_id
  end
end
