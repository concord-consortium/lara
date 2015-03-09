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

    def interactive
      # Return first interactive available on the page (note that in practice it's impossible that this model has more
      # than one page, even though it's many-to-many association).
      # In the future we can let authors explicitly select which interactive Labbook album is connected to.
      page = interactive_pages.first
      page && page.interactives.first
    end

    # Question interface.
    def prompt
      I18n.t('LABBOOK_ALBUM') # This string is visible in report.
    end
    # End of question interface.
  end
end
