class AddFullwidthToInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :fullwidth, :boolean, default: false 
  end
end
