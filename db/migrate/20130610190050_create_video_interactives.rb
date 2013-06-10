class CreateVideoInteractives < ActiveRecord::Migration
  def change
    create_table :video_interactives do |t|

      t.timestamps
    end
  end
end
