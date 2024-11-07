class StoreSequenceInRun < ActiveRecord::Migration[5.1]
  def up
    add_column :runs, :sequence_id, :integer, null: true
  end

  def down
    remove_column :runs, :sequence_id
  end
end
