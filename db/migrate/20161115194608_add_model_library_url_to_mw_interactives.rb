class AddModelLibraryUrlToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :model_library_url, :string
  end
end
