class AddDescriptionToLightweightActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :description, :text, :null => true
  end
end
