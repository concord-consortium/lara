class AddDefaultPublicationStatusToLightweightActivities < ActiveRecord::Migration
  def change
    change_column :lightweight_activities, :publication_status, :string, default: 'draft'
  end
end
