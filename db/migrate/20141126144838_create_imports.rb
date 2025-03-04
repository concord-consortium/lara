class CreateImports < ActiveRecord::Migration[5.1]
  def change
    create_table :imports do |t|
      t.string :export_site
      t.references :user
      t.references :import_item, polymorphic: true
      t.timestamps
    end
  end
end
