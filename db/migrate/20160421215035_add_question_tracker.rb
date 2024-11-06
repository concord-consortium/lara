class AddQuestionTracker < ActiveRecord::Migration
  def change
    create_table :question_trackers do |t|
      t.string :name
      t.string :description
      t.references :master_question, polymorphic: true, index: true
      t.references :user, index: true
    end
  end
end