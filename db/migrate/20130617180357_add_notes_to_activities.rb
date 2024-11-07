class AddNotesToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :notes, :text
  end
end
