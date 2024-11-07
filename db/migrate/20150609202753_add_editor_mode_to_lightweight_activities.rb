class AddEditorModeToLightweightActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :editor_mode, :integer, default: 0
  end
end
