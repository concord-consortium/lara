class AddRelatedAndSidebarContent < ActiveRecord::Migration
  def up
    add_column :lightweight_activities, :related, :text, :null => true
    add_column :interactive_pages, :sidebar, :text, :null => true
  end

  def down
    remove_column :lightweight_activities, :related
    remove_column :interactive_pages, :sidebar
  end
end
