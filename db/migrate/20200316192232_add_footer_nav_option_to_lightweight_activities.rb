class AddFooterNavOptionToLightweightActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :footer_nav, :boolean, :default => false
  end
end
