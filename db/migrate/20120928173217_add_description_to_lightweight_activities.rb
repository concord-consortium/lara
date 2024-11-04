class AddDescriptionToLightweightActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :description, :text, null: true
  end
end
