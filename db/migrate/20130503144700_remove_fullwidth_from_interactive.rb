class RemoveFullwidthFromInteractive < ActiveRecord::Migration[5.1]
  def up
    remove_column :mw_interactives, :width
    remove_column :mw_interactives, :fullwidth
  end

  def down
    add_column :mw_interactives, :width,     :float, :default => 60.0
    add_column :mw_interactives, :fullwidth, :boolean, :default => false
  end
end
