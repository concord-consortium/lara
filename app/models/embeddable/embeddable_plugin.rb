module Embeddable
  class EmbeddablePlugin < ActiveRecord::Base
    include Embeddable
    def self.table_name
      'embeddable_plugins'
    end

    attr_accessible :plugin, :approved_script_id, :description, :author_data

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

    before_create do |embeddable|
      embeddable.plugin = Plugin.create({})
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

    def self.import(import_hash)
      return self.new(import_hash)
    end

    def to_hash
      this.plugin.to_hash
    end

    def portal_hash
      {
        type: "external_plugin",
        id: id,
        plugin_id: plugin_id
      }
    end

    def duplicate
      return Embeddable::Plugin.new(self.to_hash)
    end

    def reportable?
      false
    end

    def is_hidden
      false
    end

    def is_full_width
      true
    end

    def export
      plugin.export
    end

  end
end
