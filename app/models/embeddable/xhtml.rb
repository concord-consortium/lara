module Embeddable
  class Xhtml < ActiveRecord::Base
    attr_accessible :name, :content, :is_hidden

    include Embeddable

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.

    has_many :interactive_pages, :through => :page_items

    validates :content, :html => true

    def to_hash
      {
        name: name,
        content: content,
        is_hidden: is_hidden
      }
    end

    def duplicate
      return Embeddable::Xhtml.new(self.to_hash)
    end

    def export
      self.as_json(only:[:name, :content, :is_hidden])
    end

    def reportable?
      false
    end

    def page_section
      # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
      page_items.count > 0 && page_items.first.section
    end

    def self.import(import_hash)
      return self.new(import_hash)
    end

    def self.name_as_param
      :embeddable_xhtml
    end

    def self.display_partial
      :xhtml
    end

    def self.human_description
      "XHTML block"
    end
  end
end
