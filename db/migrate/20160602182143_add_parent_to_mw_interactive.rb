class AddParentToMwInteractive < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :parent_id, :integer
    add_index :mw_interactives, :parent_id
  end
end
