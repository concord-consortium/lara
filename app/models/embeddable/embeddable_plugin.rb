module Embeddable
  class EmbeddablePlugin < ActiveRecord::Base
    include Embeddable
    include AttachedToEmbeddable

    def self.table_name
      'embeddable_plugins'
    end

    attr_accessible :plugin, :approved_script_id, :description, :author_data,
    :is_full_width, :is_hidden, :component_label

    belongs_to :plugin, autosave: true

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :interactive_pages, :through => :page_items

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

    before_create do |embeddable|
      unless(embeddable.plugin)
        embeddable.plugin = Plugin.create({})
      end
      embeddable.plugin.plugin_scope = embeddable
    end

    def self.name_as_param
      :embeddable_embeddable_plugin
    end

    def self.display_partial
      :plugin
    end

    def self.human_description
      "Plugin"
    end
    def to_hash
      {
        plugin: self.plugin.to_hash,
        is_hidden: self.is_hidden,
        is_full_width: self.is_full_width
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

    def page_section
      # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
      page_items.count > 0 && page_items.first.section
    end

    def wrapping_plugin?
      # It is if it's attached to some other embeddable.
      attached_to_embeddable
    end
  end
end
