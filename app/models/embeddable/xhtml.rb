module Embeddable
  class Xhtml < ActiveRecord::Base
    attr_accessible :name, :content

    include Embeddable

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.

    has_many :interactive_pages, :through => :page_items

    validates :content, :html => true

    def to_hash
      {
        name: name,
        content: content
      }
    end

    def duplicate
      return Embeddable::Xhtml.new(self.to_hash)
    end
    
    def export
      self.as_json(only:[:name, :content])
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
