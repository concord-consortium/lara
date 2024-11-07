class AddProjectsToGlossaries < ActiveRecord::Migration[5.1]
  def change
    add_column :glossaries, :project_id, :integer
  end
end
