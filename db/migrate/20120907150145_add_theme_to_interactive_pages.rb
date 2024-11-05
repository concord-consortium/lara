class AddThemeToInteractivePages < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :theme, :string, default: 'default'
  end
end
