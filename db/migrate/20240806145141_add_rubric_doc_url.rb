class AddRubricDocUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :rubrics, :doc_url, :string, null: true
  end
end
