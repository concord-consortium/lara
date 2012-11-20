class RemoveThemeFromInteractivePage < ActiveRecord::Migration
  def up
    remove_column :interactive_pages, :theme
  end

  def down
    add_column :interactive_pages, :theme, :string, :default => "default"
  end
end
