class AddMetadataToInteractiveRunStates < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_run_states, :metadata, :text
  end
end
