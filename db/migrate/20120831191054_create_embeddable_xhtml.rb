class CreateEmbeddableXhtml < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_xhtmls do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
