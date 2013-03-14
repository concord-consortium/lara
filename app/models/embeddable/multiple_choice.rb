module Embeddable
  class MultipleChoice < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'

    has_many :choices, :class_name => 'Embeddable::MultipleChoiceChoice', :foreign_key => 'multiple_choice_id'
    has_many :page_items, :as => :embeddable
    has_many :interactive_pages, :through => :page_items

    attr_accessible :name, :prompt, :choices_attributes
    accepts_nested_attributes_for :choices, :allow_destroy => true

    default_value_for :name, "Multiple Choice Question element"

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
    end

    def create_default_choices
      self.add_choice('a')
      self.add_choice('b')
      self.add_choice('c')
    end

    def add_choice(choice_name = "new choice")
      new_choice = Embeddable::MultipleChoiceChoice.create(:choice => choice_name, :multiple_choice => self)
      self.save
      new_choice
    end

    def custom
      custom = false
      choices.each { |c| custom = true if !c.prompt.blank? }
      custom
    end
  end
end
