class AddWidthHeightToInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :native_width, :integer
    add_column :mw_interactives, :native_height, :integer
  end
end
