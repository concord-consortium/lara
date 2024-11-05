class AddClassHashToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :class_hash, :string
  end
end
