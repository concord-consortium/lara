class RemoveDuplicatePluginId < ActiveRecord::Migration

  def up
    # need to go through all EmbeddablePlugins and make sure each of their
    # plugins correctly sets the plugin_scope field on the plugin
    # we cannot easily use the polymorphic support of rails because we are also using
    # temporary model classes, so plugin_scope_type added by the polymorphic code would
    # end up being:  RemoveDuplicatePluginId::Embeddable::EmbeddablePlugin
    execute <<-SQL
      UPDATE plugins
      INNER JOIN embeddable_plugins
      ON embeddable_plugins.plugin_id = plugins.id
      SET plugins.plugin_scope_id = embeddable_plugins.id, plugins.plugin_scope_type = "Embeddable::EmbeddablePlugin"
    SQL

    remove_column :embeddable_plugins, :plugin_id

    # the index should be removed automatically by the database
  end

  def down
    add_column :embeddable_plugins, :plugin_id, :integer
    add_index :embeddable_plugins, [:plugin_id], uniq: true

    # go through all EmbeddablePlugins and make sure for each plugin that the plugin_id
    # is set correctly on the EmbeddablePlugin
    execute <<-SQL
      UPDATE embeddable_plugins
      INNER JOIN plugins
      ON plugins.plugin_scope_id = embeddable_plugins.id
      SET embeddable_plugins.plugin_id = plugins.id
      WHERE plugins.plugin_scope_type = "Embeddable::EmbeddablePlugin"
    SQL

  end
end
