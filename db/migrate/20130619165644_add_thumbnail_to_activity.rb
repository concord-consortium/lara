class AddThumbnailToActivity < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :thumbnail_url, :string, :null => true
  end
end
