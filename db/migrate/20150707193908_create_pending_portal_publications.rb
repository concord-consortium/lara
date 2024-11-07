class CreatePendingPortalPublications < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_portal_publications do |t|
      t.integer :portal_publication_id
      t.timestamps
    end

    add_index :pending_portal_publications, :portal_publication_id, unique: true, name: 'unique_publications_per_portal'

    add_column :portal_publications, :publication_time, :int
  end
end
