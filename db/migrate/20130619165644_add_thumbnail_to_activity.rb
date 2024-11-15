class AddThumbnailToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :thumbnail_url, :string, null: true
  end
end
