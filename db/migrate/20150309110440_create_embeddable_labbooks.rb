class CreateEmbeddableLabbooks < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_labbooks do |t|
      t.timestamps
    end
  end
end
