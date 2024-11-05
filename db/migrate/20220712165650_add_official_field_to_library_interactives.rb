class AddOfficialFieldToLibraryInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :library_interactives, :official, :boolean, default: false
  end
end
