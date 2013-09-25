module Embeddable
  class MultipleChoice < ActiveRecord::Base
    has_many :choices, :class_name => 'Embeddable::MultipleChoiceChoice', :foreign_key => 'multiple_choice_id'
    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.
    has_many :interactive_pages, :through => :page_items

    has_many :answers,
      :class_name => 'Embeddable::MultipleChoiceAnswer',
      :foreign_key => 'multiple_choice_id'

    attr_accessible :name, :prompt, :custom, :choices_attributes, :enable_check_answer, :multi_answer, :show_as_menu
    accepts_nested_attributes_for :choices, :allow_destroy => true

    default_value_for :name, "Multiple Choice Question element"
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

    def to_hash
      # Leaving out "choices"
      {
        name: name,
        prompt: prompt,
        custom: custom,
        enable_check_answer: enable_check_answer,
        multi_answer: multi_answer,
        show_as_menu: show_as_menu
      }
    end

    def duplicate
      mc = Embeddable::MultipleChoice.new(self.to_hash)
      self.choices.each do |choice|
        mc.choices << choice.duplicate
      end
      return mc
    end

    def self.name_as_param
      :embeddable_multiple_choice
    end

    def self.display_partial
      :multiple_choice
    end

    def self.human_description
      "Multiple choice question"
    end
  end
end
