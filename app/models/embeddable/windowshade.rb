module Embeddable
  class Windowshade < ActiveRecord::Base
    include Embeddable
    def self.table_name
      'embeddable_plugins'
    end

    attr_accessible :plugin
    belongs_to :plugin, autosave: true

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :interactive_pages, :through => :page_items

    delegate :approved_script,  to: :plugin
    delegate :approved_script=,  to: :plugin
    delegate :author_data, to: :plugin
    delegate :author_data=, to: :plugin
    delegate :shared_learner_state_key, to: :plugin
    delegate :description, to: :plugin
    delegate :description=, to: :plugin

    before_create do |embeddable|
      embeddable.plugin = Plugin.create({})
      embeddable.plugin.plugin_scope = embeddable
    end

    def self.name_as_param
      :embeddable_plugin
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

    def export
      plugin.export
    end

  end
end
