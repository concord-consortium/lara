class AddThemeToInteractivePages < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :theme, :string, :default => 'default'
  end
end
