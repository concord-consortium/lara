class AddSentDataToPortalPublications < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_publications, :sent_data, :text
  end
end
