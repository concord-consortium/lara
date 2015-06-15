class AddIsHiddenToInteractivePages < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :is_hidden, :boolean, default: false
  end
end
