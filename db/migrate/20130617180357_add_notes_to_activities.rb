class AddNotesToActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :notes, :text
  end
end
