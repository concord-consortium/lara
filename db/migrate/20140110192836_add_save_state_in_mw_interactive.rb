class AddSaveStateInMwInteractive < ActiveRecord::Migration[5.1]
  def change
     add_column :mw_interactives, :save_state, :boolean, :default => false
  end

end
