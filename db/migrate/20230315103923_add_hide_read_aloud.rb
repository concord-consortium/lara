class AddHideReadAloud < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :hide_read_aloud, :boolean, default: false
    add_column :sequences, :hide_read_aloud, :boolean, default: false
  end
end
