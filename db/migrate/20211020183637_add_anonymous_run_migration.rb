class AddAnonymousRunMigration < ActiveRecord::Migration
  def change
    # generic status column, added now to track if anonymous run have been copied to Firebase
    # maybe useful later for other reasons and thus the generic column name instead of a boolean flag
    add_column :runs, :status, :integer, default: 0

    # we need these two fields to be indexed to select a subset of records to copy to Firebase
    add_index :runs, :updated_at
    add_index :runs, :status
  end
end
