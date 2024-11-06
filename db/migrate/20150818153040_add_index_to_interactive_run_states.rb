class AddIndexToInteractiveRunStates < ActiveRecord::Migration
  def change
    add_index "interactive_run_states", ["run_id"], :name => "interactive_run_states_run_id_idx"
  end
end
