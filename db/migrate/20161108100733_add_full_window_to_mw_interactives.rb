class AddFullWindowToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :full_window, :boolean, default: false
  end
end
