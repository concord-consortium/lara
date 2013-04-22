module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    attr_accessible :answer_ids, :answer_texts, :run, :question

    belongs_to :question,
      :class_name  => 'Embeddable::MultipleChoice',
      :foreign_key => 'multiple_choice_id'

    belongs_to :run

    has_and_belongs_to_many :answers,
      :class_name => 'Embeddable::MultipleChoiceChoice',
      :join_table => 'mc_answer_choices',
      :foreign_key => 'answer_id',
      :association_foreign_key => 'choice_id'

    scope :by_question, lambda { |q|
      {:conditions => { :multiple_choice_id => q.id}}
    }

    scope :by_run, lambda { |r|
      {:conditions => { :run_id => r.id }}
    }

    delegate :prompt,  :to  => :question
    delegate :choices, :to  => :question

    # render the text of the answers
    def answer_texts
      self.answers.map { |a| a.choice }
    end

  end

end