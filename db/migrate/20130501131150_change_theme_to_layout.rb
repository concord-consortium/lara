class ChangeThemeToLayout < ActiveRecord::Migration[5.1]
  def up
    # We haven't needed this in ages
    remove_column :interactive_pages, :offerings_count
    add_column :interactive_pages, :layout, :string, default: 'l-6040'
  end

  def down
    add_column :interactive_pages, :offerings_count, :integer, default: 0
    remove_column :interactive_pages, :layout
  end
end
