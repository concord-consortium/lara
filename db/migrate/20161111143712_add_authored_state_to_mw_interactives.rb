class AddAuthoredStateToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :authored_state, :text
  end
end
