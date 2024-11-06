class RemovingOwnerships < ActiveRecord::Migration
  def up
    remove_column :interactive_pages, :user_id
    remove_column :mw_interactives, :user_id
  end

  def down
    add_column :interactive_pages, :user_id, :integer
    add_column :mw_interactives, :user_id, :integer
  end
end
