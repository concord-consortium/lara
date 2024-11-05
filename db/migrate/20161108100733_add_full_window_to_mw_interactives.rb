class AddFullWindowToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :full_window, :boolean, default: false
  end
end
