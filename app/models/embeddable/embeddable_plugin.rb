module Embeddable
  class EmbeddablePlugin < ActiveRecord::Base
    include Embeddable
    include AttachedToEmbeddable

    def self.table_name
      'embeddable_plugins'
    end

    attr_accessible :plugin, :approved_script_id, :description, :author_data,
    :is_half_width, :is_hidden, :component_label, :name, :label, :url

    has_one :plugin, as: :plugin_scope, autosave: true

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :sections, through: :page_items
    has_many :interactive_pages, through: :sections

    delegate :approved_script,  to: :plugin
    delegate :approved_script=,  to: :plugin
    delegate :approved_script_id,  to: :plugin
    delegate :approved_script_id=,  to: :plugin
    delegate :author_data, to: :plugin
    delegate :author_data=, to: :plugin
    delegate :shared_learner_state_key, to: :plugin
    delegate :description, to: :plugin
    delegate :description=, to: :plugin
    delegate :name,  to: :plugin, allow_nil: true
    delegate :label, to: :plugin, allow_nil: true
    delegate :url, to: :plugin, allow_nil: true
    delegate :component_label, to: :plugin
    delegate :component_label=, to: :plugin
    delegate :component, to: :plugin, allow_nil: true

    # make sure the embeddable always has a plugin object
    after_initialize do |embeddable|
      unless(embeddable.plugin)
        # Building the plugin seems safer than creating the plugin so when we do a simple
        # EmbeddablePlugin.new that doesn't trigger the creation of a Plugin object in the
        # database.
        # when the embeddable is saved, the plugin will be saved too becaue of the
        # has_one relationship. Documentation reference:
        # https://guides.rubyonrails.org/v3.2.13/association_basics.html#has_one-when_are_objects_saved
        embeddable.build_plugin
      end
    end

    def self.name_as_param
      :embeddable_embeddable_plugin
    end

    def self.display_partial
      :plugin
    end

    def update_attributes(attributes)
      # NP 2022-05-27: We need to clear-out some delageted read-only
      # attributes that should not be updated. You would think this would
      # be handled by `attr_accessible`, however because of uniformity
      # in how we update embeddables, we choose to do this manually here.
      attributes.delete(:name)
      attributes.delete(:url)
      attributes.delete(:label)
      super
    end

    def authoring_api_urls(protocol, host)
      {
        update_plugin_author_data: Rails.application.routes.url_helpers.api_v1_update_plugin_author_data_url(
          {
            plugin_id: plugin.id,
            protocol: protocol,
            host: host
          }
        )
      }
    end

    def to_hash
      {
        plugin: self.plugin.to_hash,
        is_hidden: self.is_hidden,
        is_half_width: self.is_half_width
      }
    end

    # NP 2022-05-27: For uniformity with other embeddables
    # Flatten out the plugin content for editing
    def to_editing_hash
      {
        is_hidden: is_hidden,
        is_half_width: is_half_width,
        name: name,
        label: label,
        url: url,
        component_label: component_label,
        author_data: author_data
      }
    end


    # NP: 2018-11-06 probably not needed at the moment...
    def portal_hash
      {
        type: "embeddable_plugin",
        id: id,
        plugin: plugin.to_hash
      }
    end

    def self.import(import_hash)
      plugin_hash = import_hash.delete(:plugin)
      copy =  Embeddable::EmbeddablePlugin.new(import_hash)
      copy.plugin = Plugin.import(plugin_hash)
      return copy
    end

    def duplicate
      hash_values = self.to_hash
      return EmbeddablePlugin.import(hash_values)
    end

    def reportable?
      false
    end

    def export
      self.to_hash
    end

    def wrapping_plugin?
      # It is if it's attached to some other embeddable.
      attached_to_embeddable
    end

    def show_in_edit?
      # if this plugin component is intended to wrap an embeddable (embeddable-decoration),
      # but the embeddable has been deleted, wrapping_plugin? will return false.
      # So the plugin will show up in authoring.
      # Currently if a LARA author tries to edit a plugin in this state an error is shown
      # in the console but no error is shown to the author.
      # But at least with this approach the author can delete this misconfigured plugin.
      !wrapping_plugin?
    end

    # embeddable_plugins are one type of plugin_scope used by plugins
    # the authorization code expects the plugin_scope to have a user_id
    def user_id
      activity && activity.user_id
    end
  end
end
