class RemoveTrackedQuestions < ActiveRecord::Migration[5.2]
  def up
    drop_table :tracked_questions
  end
  def down
    create_table :tracked_questions do |t|
      t.references :question_tracker, index: true
      t.references :question, polymorphic: true, index: true
    end
  end
end
