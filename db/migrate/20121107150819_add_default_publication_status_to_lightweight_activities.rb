class AddDefaultPublicationStatusToLightweightActivities < ActiveRecord::Migration[5.1]
  def change
    change_column :lightweight_activities, :publication_status, :string, :default => 'draft'
  end
end
