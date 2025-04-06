class RemoveQuestionTracker < ActiveRecord::Migration[5.2]
  def up
    drop_table :question_trackers
  end
  def down
    create_table :question_trackers do |t|
      t.string :name
      t.string :description
      # Use `index: false` to prevent Rails from creating its own index automatically
      t.references :master_question, polymorphic: true, index: false
      t.references :user, index: true
    end

    add_index :question_trackers, [:master_question_id, :master_question_type], name: 'index_question_trackers_on_master_question'
  end
end
