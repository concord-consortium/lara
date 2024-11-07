class AddEmbeddableToPlugins < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_plugins, :embeddable_id, :integer
    add_column :embeddable_plugins, :embeddable_type, :string
  end
end
