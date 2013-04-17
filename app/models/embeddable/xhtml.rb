module Embeddable
  class Xhtml < ActiveRecord::Base
    attr_accessible :name, :content
    has_many :page_items, :as => :embeddable
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
  end
end
