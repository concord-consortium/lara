class AddCustomizableToLibraryInteractives < ActiveRecord::Migration
  def change
    add_column :library_interactives, :customizable, :boolean, :default => false
    add_column :library_interactives, :authorable, :boolean, :default => false
  end
end
