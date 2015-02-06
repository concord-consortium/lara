class AddAdditionalSectionsToInteractivePage < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :additional_sections, :text
  end
end
