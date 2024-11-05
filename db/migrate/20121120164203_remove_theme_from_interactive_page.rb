class RemoveThemeFromInteractivePage < ActiveRecord::Migration[5.1]
  def up
    remove_column :interactive_pages, :theme
  end

  def down
    add_column :interactive_pages, :theme, :string, :default => "default"
  end
end
