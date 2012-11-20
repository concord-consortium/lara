module Embeddable
  class MultipleChoice < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :name, :prompt, :choices

    has_many :choices, :class_name => 'Embeddable::MultipleChoiceChoice', :foreign_key => 'multiple_choice_id'

    default_value_for :name, "Multiple Choice Question element"
    default_value_for :prompt, "Why do you think ..."

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
  end
end
