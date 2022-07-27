class AddOfficialFieldToLibraryInteractives < ActiveRecord::Migration
  def change
    add_column :library_interactives, :official, :boolean, default: false
  end
end
