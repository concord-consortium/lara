class AddAutoPublishUrl < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :auto_publish_url, :string
    add_column :sequences, :auto_publish_url, :string
  end
end
