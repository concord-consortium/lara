module Embeddable
  class OpenResponse < ActiveRecord::Base
    attr_accessible :name, :prompt
    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.
    has_many :interactive_pages, :through => :page_items

    has_many :answers,
      :class_name  => 'Embeddable::OpenResponseAnswer',
      :foreign_key => 'open_response_id'

    default_value_for :prompt, "why does ..."

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

    def to_hash
      {
        name: name,
        prompt: prompt
      }
    end

    def duplicate
      return Embeddable::OpenResponse.new(self.to_hash)
    end
  end
end
