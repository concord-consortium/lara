class AddSidebarTitleToInteractivePage < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :sidebar_title, :string, :default => "Did you know?"
  end
end
