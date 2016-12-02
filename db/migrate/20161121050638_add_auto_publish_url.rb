class AddAutoPublishUrl < ActiveRecord::Migration
  def change
    add_column :portal_publications, :auto_publish_url, :string
  end
end
