class AddProjectAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :project_admins do |t|
      t.references :user, index: true
      t.references :project, index: true

      t.timestamps
    end

    add_index :project_admins, [:user_id, :project_id], unique: true
  end
end
