class AddThemeToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :theme_id, :integer
  end
end
