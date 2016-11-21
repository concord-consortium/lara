class AddAutoPublishUrl < ActiveRecord::Migration
  def change
    add_column :pending_portal_publications, :auto_publish_url, :string
  end
end
