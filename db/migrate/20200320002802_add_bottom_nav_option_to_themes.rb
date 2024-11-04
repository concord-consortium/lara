class AddBottomNavOptionToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :footer_nav, :boolean, default: false
  end
end
