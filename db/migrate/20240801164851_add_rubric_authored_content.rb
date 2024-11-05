class AddRubricAuthoredContent < ActiveRecord::Migration[5.1]
  def up
    change_table :rubrics do |t|
      t.references :authored_content
    end
  end
  def down
    change_table :rubrics do |t|
      t.remove :authored_content_id
    end
  end
end
