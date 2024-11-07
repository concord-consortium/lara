class AddWidthToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :width, :float, default: 60.0
  end
end
