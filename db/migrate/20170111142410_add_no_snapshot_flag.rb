class AddNoSnapshotFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :no_snapshots, :boolean, default: false
  end
end
