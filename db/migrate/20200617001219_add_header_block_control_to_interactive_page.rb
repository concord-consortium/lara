class AddHeaderBlockControlToInteractivePage < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :show_header, :boolean, default: false
  end
end
