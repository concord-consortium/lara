class AddEditorModeToLightweightActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :editor_mode, :integer, default: 0
  end
end
