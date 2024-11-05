class CreateMwInteractives < ActiveRecord::Migration[5.1]
  def change
    create_table :mw_interactives do |t|
      t.string :name
      t.string :url
      t.integer :user_id

      t.timestamps
    end

    add_index :mw_interactives, :user_id, :name => 'mw_interactives_user_idx'
  end
end
