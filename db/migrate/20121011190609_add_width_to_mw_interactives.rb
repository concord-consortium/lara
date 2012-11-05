class AddWidthToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :width, :float, :default => 60.0
  end
end
