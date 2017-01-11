class AddNoSnapshotFlag < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :no_snapshots, :boolean, default: false
  end
end
