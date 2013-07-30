class AddThemeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :theme_id, :integer
  end
end
