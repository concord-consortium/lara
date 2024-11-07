class AddBottomNavOptionToThemes < ActiveRecord::Migration[5.1]
  def change
    add_column :themes, :footer_nav, :boolean, default: false
  end
end
