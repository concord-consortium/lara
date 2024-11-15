class AddIndexToPortalPublications < ActiveRecord::Migration[5.1]
  def change
    add_index :portal_publications, [:publishable_id, :publishable_type]
  end
end
