module Embeddable
  class Xhtml < ActiveRecord::Base
    attr_accessible :name, :content, :is_hidden, :is_half_width, :is_callout

    include Embeddable

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.

    has_many :sections, through: :page_items
    has_many :interactive_pages, through: :sections

    validates :content, :html => true

    def to_hash
      {
        name: name,
        content: content,
        is_hidden: is_hidden,
        is_half_width: is_half_width,
        is_callout: is_callout
      }
    end

    def duplicate
      return Embeddable::Xhtml.new(self.to_hash)
    end

    def export
      self.as_json(only:[:name, :content, :is_hidden, :is_half_width, :is_callout])
    end

    def reportable?
      false
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
  end
end
