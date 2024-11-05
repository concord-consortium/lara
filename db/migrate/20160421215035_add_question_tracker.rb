class AddQuestionTracker < ActiveRecord::Migration[5.1]
  def change
    create_table :question_trackers do |t|
      t.string :name
      t.string :description
      # Use `index: false` to prevent Rails from creating its own index automatically
      t.references :master_question, polymorphic: true, index: false
      t.references :user, index: true
    end
  end
end