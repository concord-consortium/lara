class CreatePortalPublications < ActiveRecord::Migration
  def change
    create_table :portal_publications do |t|
      t.string :portal_url
      t.string :response
      t.boolean :success
      t.integer :lightweight_activity_id
      t.integer :sequence_id
      # updated_at will serve for the time of publication
      t.timestamps
    end
  end
end
