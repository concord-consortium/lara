class AddFullwidthToInteractive < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :fullwidth, :boolean, default: false 
  end
end
