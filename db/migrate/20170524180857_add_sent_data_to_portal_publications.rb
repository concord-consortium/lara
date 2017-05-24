class AddSentDataToPortalPublications < ActiveRecord::Migration
  def change
    add_column :portal_publications, :sent_data, :text
  end
end
