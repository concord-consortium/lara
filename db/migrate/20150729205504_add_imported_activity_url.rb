class AddImportedActivityUrl < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :imported_activity_url, :string
    add_column :sequences, :imported_activity_url, :string
  end
end
