class AddIndexToPortalPublications < ActiveRecord::Migration
  def change
    add_index :portal_publications, [:publishable_id, :publishable_type]
  end
end
