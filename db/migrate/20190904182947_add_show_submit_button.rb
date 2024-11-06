class AddShowSubmitButton < ActiveRecord::Migration
  def up
    add_column :lightweight_activities, :show_submit_button, :boolean, :default => true
  end

  def down
    remove_column :lightweight_activities, :show_submit_button
  end
end
