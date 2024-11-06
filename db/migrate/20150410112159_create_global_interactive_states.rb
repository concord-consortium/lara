class CreateGlobalInteractiveStates < ActiveRecord::Migration
  def change
    create_table :global_interactive_states do |t|
      t.integer :run_id
      t.text :raw_data

      t.timestamps
    end
    add_index :global_interactive_states, :run_id
  end
end
