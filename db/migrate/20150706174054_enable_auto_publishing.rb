class EnableAutoPublishing < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_publications, :publication_hash, :string, limit: 40
    add_column :lightweight_activities, :publication_hash, :string, limit: 40
    add_column :sequences, :publication_hash, :string, limit: 40
  end
end
