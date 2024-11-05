class CreateActivityResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :activity_responses do |t|
      t.string :key, :null => false
      t.text :responses
      t.integer :activity_id, :null => false
      t.integer :user_id, :null => true

      t.timestamps
    end
  end
end
