class AddClassHashToRun < ActiveRecord::Migration
  def change
    add_column :runs, :class_info_url, :text
  end
end
