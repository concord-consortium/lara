class AddShowDataButtonToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :show_delete_data_button, :boolean, default: true
  end
end
