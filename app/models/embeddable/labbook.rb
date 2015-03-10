# Labbook class represents an embeddable item, "question", authorable part of the activity page.
module Embeddable
  class Labbook < ActiveRecord::Base
    include Embeddable

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :interactive_pages, :through => :page_items

    # "Answer" isn't the best word probably, but it fits the rest of names and convention.
    # LabbookAnswer is an instance related to particular activity run and user.
    has_many :answers,
             :class_name  => 'Embeddable::LabbookAnswer'

    def self.portal_type
      # Note that the same type is also used by MwInteractive.
      'iframe interactive'
    end

    def portal_id
      # We have to add prefix to ID to make sure that there are no conflicts
      # between various LARA classes using the same portal type (e.g. MwInteractive).
      "#{self.class.name}_#{id}"
    end

    # Question interface.
    def portal_hash
      {
        # This is ridiculous, but portal sometimes uses 'iframe interactive' and sometimes 'iframe_interactive'...
        type: self.class.portal_type.gsub(' ', '_'),
        id: portal_id,
        name: 'Labbook album',
        # This info can be used by Portal to generate an iframe.
        native_width: 600,
        native_height: 500
      }
    end

    def prompt
      I18n.t('LABBOOK_ALBUM') # This string is visible in report.
    end

    def to_hash
      {}
    end

    def duplicate
      self.class.new(self.to_hash)
    end

    def export
      return self.as_json(only: [])
    end

    def self.import(import_hash)
      self.new(import_hash)
    end
    # End of question interface.

    def interactive
      # Return first interactive available on the page (note that in practice it's impossible that this model has more
      # than one page, even though it's many-to-many association).
      # In the future we can let authors explicitly select which interactive Labbook album is connected to.
      page = interactive_pages.first
      page && page.interactives.first
    end
  end
end
