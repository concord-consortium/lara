module Embeddable
  class ExternalScript < ApplicationRecord
    include Embeddable

    # PageItem instances are join models, so if the embeddable is gone the join should go too.
    belongs_to :approved_script
    has_many :page_items, as: :embeddable, dependent: :destroy
    has_many :sections, through: :page_items
    has_many :interactive_pages, through: :sections
    has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref
    has_many :embeddable_plugins, class_name: "Embeddable::EmbeddablePlugin", as: :embeddable
    delegate :name,  to: :approved_script, allow_nil: true
    delegate :label, to: :approved_script, allow_nil: true
    delegate :url,   to: :approved_script, allow_nil: true

    def self.name_as_param
      :embeddable_external_script
    end

    def self.display_partial
      :external_script
    end

    def self.import(import_hash)
      return self.new(import_hash)
    end

    def to_hash
      {
        approved_script_id: approved_script_id,
        configuration: configuration,
        description: description
      }
    end

    def portal_hash
      {
        type: "external_script",
        id: id,
        url: url,
        configuration: configuration,
        name: name
      }
    end

    def duplicate
      return Embeddable::ExternalScript.new(self.to_hash)
    end

    def reportable?
      false
    end

    def is_hidden
      false
    end

    def is_hidden?
      is_hidden
    end

    def export
      return self.as_json(only:[:name, :url, :configuration, :description])
    end

  end
end
