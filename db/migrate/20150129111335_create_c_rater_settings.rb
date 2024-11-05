class CreateCRaterSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :c_rater_settings do |t|
      t.integer :item_id
      t.references :score_mapping
      t.references :provider, polymorphic: true

      t.timestamps
    end
    unless index_exists?(:c_rater_settings, :score_mapping_id)
      add_index :c_rater_settings, :score_mapping_id
    end
    add_index :c_rater_settings, [:provider_id, :provider_type]
  end
end
