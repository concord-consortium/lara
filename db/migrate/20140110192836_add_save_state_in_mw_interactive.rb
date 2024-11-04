class AddSaveStateInMwInteractive < ActiveRecord::Migration
  def change
     add_column :mw_interactives, :save_state, :boolean, default: false
  end

end
