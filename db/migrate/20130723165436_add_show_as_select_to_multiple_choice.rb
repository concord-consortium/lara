class AddShowAsSelectToMultipleChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choices, :show_as_menu, :boolean, default: false
  end
end
