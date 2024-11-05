class AddClassHashToRun < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :class_info_url, :text
  end
end
