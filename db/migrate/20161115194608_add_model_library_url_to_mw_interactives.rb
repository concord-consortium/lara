class AddModelLibraryUrlToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :model_library_url, :string
  end
end
