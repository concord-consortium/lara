class CreateApprovedScripts < ActiveRecord::Migration[5.1]
  def change
    create_table :approved_scripts do |t|
      t.string :name
      t.string :url
      t.text :description

      t.timestamps
    end
  end
end
