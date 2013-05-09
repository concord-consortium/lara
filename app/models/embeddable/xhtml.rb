module Embeddable
  class Xhtml < ActiveRecord::Base
    attr_accessible :name, :content

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.

    has_many :interactive_pages, :through => :page_items

    def activity
      if interactive_pages.length > 0
        if interactive_pages.first.lightweight_activity.present?
          return interactive_pages.first.lightweight_activity
        else
          return nil
        end
      else
        return nil
      end
    end

    def to_hash
      {
        name: name,
        content: content
      }
    end

    def duplicate
      return Embeddable::Xhtml.new(self.to_hash)
    end
  end
end
