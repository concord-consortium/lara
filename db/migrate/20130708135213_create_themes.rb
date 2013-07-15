class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :name
      t.text   :footer
      t.string :css_file

      t.timestamps
    end
  end
end
