class AddIsHiddenToEmbeddablePlugins < ActiveRecord::Migration
  def change
    add_column :embeddable_plugins, :is_hidden, :boolean, default: false
    add_column :embeddable_plugins, :is_full_width, :boolean, default: false
  end
end
