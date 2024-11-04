class AddThemeToActivitiesAndSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :theme, :string, default: nil
    add_column :lightweight_activities, :theme, :string, default: nil
  end
end
