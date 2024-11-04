class AddRubricDocUrl < ActiveRecord::Migration
  def change
    add_column :rubrics, :doc_url, :string, null: true
  end
end
