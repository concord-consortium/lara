class CreateGlossaries < ActiveRecord::Migration
  def change
    create_table :glossaries do |t|
      t.string :name
      t.text :json
      t.integer :user_id

      t.timestamps
    end

    add_column :lightweight_activities, :glossary_id, :integer, :null => true
  end
end
