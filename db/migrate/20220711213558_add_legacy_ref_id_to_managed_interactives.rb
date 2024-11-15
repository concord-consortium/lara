class AddLegacyRefIdToManagedInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :managed_interactives, :legacy_ref_id, :string
  end
end