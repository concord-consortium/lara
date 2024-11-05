class ConvertInteractiveItemsToPageItems < ActiveRecord::Migration[5.1]
  def up
    execute "INSERT INTO page_items (interactive_page_id, embeddable_id, embeddable_type, position, created_at, updated_at, section) SELECT interactive_page_id, interactive_id, interactive_type, position, created_at, updated_at, 'interactive_box' FROM interactive_items"
  end

  def down
    execute "DELETE FROM page_items WHERE section='interactive_box'"
  end
end
