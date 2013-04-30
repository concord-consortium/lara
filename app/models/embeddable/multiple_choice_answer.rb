module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    attr_accessible :answers, :run, :question

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

    after_update :send_to_portal

    # render the text of the answers
    def answer_texts
      self.answers.map { |a| a.choice }
    end

    def portal_hash
      {
        "type"          => "multiple_choice",
        "question_id"   => question.id.to_s,
        "answer_ids"    => answers.map { |a| a.id.to_s },
        "answer_texts"  => answer_texts
      }
    end

    def send_to_portal
      run.send_to_portal(self) if run
    end

    def to_json
      portal_hash.to_json
    end

    # Expects a parameters hash. Normalizes to allow update_attributes.
    def update_from_form_params(params)
      if params[:answers].kind_of?(Array)
        params[:answers] = params[:answers].map { |a| Embeddable::MultipleChoiceChoice.find(a) }
      else
        params[:answers] = [Embeddable::MultipleChoiceChoice.find(params[:answers])]
      end
      return self.update_attributes(params)
    end
  end

end