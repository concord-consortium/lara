class AddClassHashToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :class_hash, :string
  end
end
