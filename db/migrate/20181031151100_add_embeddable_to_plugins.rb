class AddEmbeddableToPlugins < ActiveRecord::Migration
  def change
    add_column :embeddable_plugins, :embeddable_id, :integer
    add_column :embeddable_plugins, :embeddable_type, :string
  end
end
