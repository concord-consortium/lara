class AddSettingsModel < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.text :value

      t.timestamps
    end

    add_index :settings, [:key], uniq: true
  end
end
