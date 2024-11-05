class CreateRubrics < ActiveRecord::Migration[5.1]
  def change
    create_table :rubrics do |t|
      t.string :name
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end

    add_column :lightweight_activities, :rubric_id, :integer, :null => true
  end
end
