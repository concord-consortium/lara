module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    attr_accessible :answer_ids, :answer_texts, :run, :question

    serialize  :answer_ids,   Array
    serialize  :answer_texts, Array

    belongs_to :question,
      :class_name  => 'Embeddable::MultipleChoice',
      :foreign_key => 'multiple_choice_id'

    belongs_to :run

    scope :by_question, lambda { |q|
      {:conditions => { :multiple_choice_id => q.id}}
    }

    scope :by_run, lambda { |r|
      {:conditions => { :run_id => r.id }}
    }

    delegate :prompt,  :to  => :question
    delegate :choices, :to  => :question
  end
end