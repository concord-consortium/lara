class AddInteractiveRunState < ActiveRecord::Migration[5.1]

  def change
    create_table(:interactive_run_states) do |t|
      t.references :interactive, polymorphic: true, index: { name: 'index_interactive_run_states_on_interactive' }
      t.references :run
      t.text :raw_data
      t.timestamps
    end
  end

end
