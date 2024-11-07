class AddShowSubmitButton < ActiveRecord::Migration[5.1]
  def up
    add_column :lightweight_activities, :show_submit_button, :boolean, default: true
  end

  def down
    remove_column :lightweight_activities, :show_submit_button
  end
end
