class AddIsCompletionToInteractivePage < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :is_completion, :boolean, default: false
  end
end
