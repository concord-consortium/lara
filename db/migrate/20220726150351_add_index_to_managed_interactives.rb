class AddIndexToManagedInteractives < ActiveRecord::Migration[5.1]
  def change
    add_index :managed_interactives, [:legacy_ref_id, :legacy_ref_type], name: 'managed_interactive_legacy_idx'
  end
end
