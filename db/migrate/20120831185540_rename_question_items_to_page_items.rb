class RenameQuestionItemsToPageItems < ActiveRecord::Migration[5.1]
  def change
    rename_table :question_items, :page_items

    rename_column :page_items, :question_id, :embeddable_id
    rename_column :page_items, :question_type, :embeddable_type
  end
end
