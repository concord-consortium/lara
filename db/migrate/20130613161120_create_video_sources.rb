class CreateVideoSources < ActiveRecord::Migration[5.1]
  def change
    create_table :video_sources do |t|
      t.string :url, :null => false
      t.string :format, :null => false
      t.integer :video_interactive_id
      t.timestamps
    end
  end
end
