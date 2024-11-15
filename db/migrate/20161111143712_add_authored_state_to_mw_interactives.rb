class AddAuthoredStateToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :authored_state, :text
  end
end
