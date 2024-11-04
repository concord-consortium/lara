class AddSequenceRunKey < ActiveRecord::Migration
  def up
    add_column :sequence_runs, :key, :string
    add_index :sequence_runs, :key, name: 'sequence_runs_key_idx'

    # create random key for the existing sequence run
    SequenceRun.find_each do |sequence_run|
      sequence_run.key = SequenceRun.generate_key
      sequence_run.save
    end
  end

  def down
    remove_index :sequence_runs, name: 'sequence_runs_key_idx'
    remove_column :sequence_runs, :key
  end
end
