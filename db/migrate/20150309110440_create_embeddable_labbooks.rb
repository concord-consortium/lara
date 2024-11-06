class CreateEmbeddableLabbooks < ActiveRecord::Migration
  def change
    create_table :embeddable_labbooks do |t|
      t.timestamps
    end
  end
end
