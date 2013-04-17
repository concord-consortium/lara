module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    attr_accessible :answer_ids, :answer_texts, :run_id
    serialize  :answer_ids,   Array
    serialize  :answer_texts, Array

    belongs_to :question,
      :class_name  => 'Embeddable::MultipleChoice',
      :foreign_key => 'multiple_choice_id'
    belongs_to :run
  end
end