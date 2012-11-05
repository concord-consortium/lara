module Embeddable
  class MultipleChoice < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :name, :prompt, :choices

    has_many :choices, :class_name => 'Embeddable::MultipleChoiceChoice', :foreign_key => 'multiple_choice_id'
  end
end
