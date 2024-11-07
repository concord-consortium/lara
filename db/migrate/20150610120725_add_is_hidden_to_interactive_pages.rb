class AddIsHiddenToInteractivePages < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :is_hidden, :boolean, default: false
  end
end
