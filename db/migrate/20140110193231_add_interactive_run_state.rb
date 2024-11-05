class AddInteractiveRunState < ActiveRecord::Migration[5.1]

  def change
    create_table(:interactive_run_states) do |t|
      t.references :interactive, polymorphic: true
      t.references :run
      t.text :raw_data
      t.timestamps
    end
  end

end
