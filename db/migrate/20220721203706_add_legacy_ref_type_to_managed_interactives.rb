class AddLegacyRefTypeToManagedInteractives < ActiveRecord::Migration[5.1]
  def up
    change_column :managed_interactives, :legacy_ref_id, :integer
    add_column :managed_interactives, :legacy_ref_type, :string
  end
  def down
    change_column :managed_interactives, :legacy_ref_id, :string
    remove_column :managed_interactives, :legacy_ref_type
  end
end
