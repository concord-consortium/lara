class AddAdditionalSectionsToInteractivePage < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :additional_sections, :text
  end
end
