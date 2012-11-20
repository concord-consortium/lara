module Embeddable
  class MultipleChoice < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'

    has_many :choices, :class_name => 'Embeddable::MultipleChoiceChoice', :foreign_key => 'multiple_choice_id'

    attr_accessible :name, :prompt, :choices_attributes
    accepts_nested_attributes_for :choices

    default_value_for :name, "Multiple Choice Question element"

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
