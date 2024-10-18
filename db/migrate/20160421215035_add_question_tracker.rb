class AddQuestionTracker < ActiveRecord::Migration
  def change
    create_table :question_trackers do |t|
      t.string :name
      t.string :description
      t.references :master_question, polymorphic: true
      t.references :user, index: true
    end

    add_index :question_trackers, [:master_question_id, :master_question_type], name: 'index_question_trackers_on_master_question'
  end
end