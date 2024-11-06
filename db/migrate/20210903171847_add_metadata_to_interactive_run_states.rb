class AddMetadataToInteractiveRunStates < ActiveRecord::Migration
  def change
    add_column :interactive_run_states, :metadata, :text
  end
end
