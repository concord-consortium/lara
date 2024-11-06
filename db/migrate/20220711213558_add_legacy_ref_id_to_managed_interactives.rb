class AddLegacyRefIdToManagedInteractives < ActiveRecord::Migration
  def change
    add_column :managed_interactives, :legacy_ref_id, :string
  end
end