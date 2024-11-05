class CreateSequenceRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :sequence_runs do |t|
      t.integer :user_id
      t.integer :sequence_id
      t.string :remote_id
      t.string :remote_endpoint
      t.timestamps
    end
    add_column :runs, :sequence_run_id, :integer
  end
end
