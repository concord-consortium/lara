class AddHelpToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :help, :text
  end
end
