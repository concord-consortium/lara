class AddProjectsToGlossaries < ActiveRecord::Migration
  def change
    add_column :glossaries, :project_id, :integer
  end
end
