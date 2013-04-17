module Embeddable
  class OpenResponse < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :name, :prompt
    has_many :page_items, :as => :embeddable
    has_many :interactive_pages, :through => :page_items

    has_many :answers,
      :class_name  => 'Embeddable::OpenResponseAnswer',
      :foreign_key => 'open_response_id'

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

    # A unique key to use for local storage
    def storage_key
      sk = "#{id}"
      if name.present?
        sk = "#{sk}_#{name.downcase.gsub(/ /, '_')}"
      end
      if interactive_pages.length > 0
        if interactive_pages.first.lightweight_activity
          sk = "#{interactive_pages.first.lightweight_activity.id}_#{interactive_pages.first.id}_#{sk}"
        else
          sk = "#{interactive_pages.first.id}_#{sk}"
        end
      end
      sk
    end
  end
end
