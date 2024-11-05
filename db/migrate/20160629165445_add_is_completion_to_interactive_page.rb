class AddIsCompletionToInteractivePage < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :is_completion, :boolean, :default => false
  end
end
