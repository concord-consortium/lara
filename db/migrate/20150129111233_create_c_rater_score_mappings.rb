class CreateCRaterScoreMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :c_rater_score_mappings do |t|
      t.text :mapping

      t.timestamps
    end
  end
end
