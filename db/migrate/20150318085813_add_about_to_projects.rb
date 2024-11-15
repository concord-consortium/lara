class AddAboutToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :about, :text
  end
end
