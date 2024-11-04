class AddHeaderBlockControlToInteractivePage < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :show_header, :boolean, default: false
  end
end
