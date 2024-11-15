class AddPluginEmbeddable < ActiveRecord::Migration[5.1]
  def change
    create_table :embeddable_plugins do |t|
      t.integer  :plugin_id
      t.timestamps
    end

    add_index :embeddable_plugins, [:plugin_id], unique: true
  end
end
