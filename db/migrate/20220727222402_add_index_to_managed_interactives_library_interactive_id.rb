class AddIndexToManagedInteractivesLibraryInteractiveId < ActiveRecord::Migration
  def change
    add_index :managed_interactives, :library_interactive_id, :name => "managed_interactive_library_interactive_id_idx"
  end
end
