class CreatePlugin < ActiveRecord::Migration[5.1]
  def change
    create_table :plugins do |t|
      t.string  :approved_script_id
      t.integer :plugin_scope_id
      t.string  :plugin_scope_type
      t.text    :author_data
      t.text    :description
      t.timestamps
    end

    add_index :plugins, [:plugin_scope_id, :plugin_scope_type], name: 'plugin_scopes', unique: false
  end
end
