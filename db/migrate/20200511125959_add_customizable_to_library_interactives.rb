class AddCustomizableToLibraryInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :library_interactives, :customizable, :boolean, default: false
    add_column :library_interactives, :authorable, :boolean, default: false
  end
end
