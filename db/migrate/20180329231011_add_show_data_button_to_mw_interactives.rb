class AddShowDataButtonToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :show_delete_data_button, :boolean, default: true
  end
end
