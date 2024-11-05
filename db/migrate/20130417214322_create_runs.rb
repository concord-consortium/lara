class CreateRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :runs do |t|
      t.integer :user_id
      t.integer :run_count

      t.timestamps
    end
  end
end
