class CreateEmbeddableXhtml < ActiveRecord::Migration
  def change
    create_table :embeddable_xhtmls do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
