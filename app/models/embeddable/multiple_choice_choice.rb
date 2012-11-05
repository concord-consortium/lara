module Embeddable
  class MultipleChoiceChoice < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :multiple_choice, :choice, :prompt

    belongs_to :multiple_choice, :class_name => "Embeddable::MultipleChoice"
  end
end
