class UpdateProjectFields < ActiveRecord::Migration
  def change
    rename_column :projects, :logo, :logo_lara
    add_column :projects, :logo_ap, :string
    add_column :projects, :project_key, :string
    add_index :projects, :project_key, unique: true
  end
end
