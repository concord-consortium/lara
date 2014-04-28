module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    include Answer # Common methods for Answer models

    attr_accessible :answers, :run, :question, :is_dirty, :is_final

    belongs_to :question,
      :class_name  => 'Embeddable::MultipleChoice',
      :foreign_key => 'multiple_choice_id'

    belongs_to :run

    has_and_belongs_to_many :answers,
      :class_name => 'Embeddable::MultipleChoiceChoice',
      :join_table => 'mc_answer_choices',
      :foreign_key => 'answer_id',
      :association_foreign_key => 'choice_id'

    delegate :name,                :to  => :question
    delegate :prompt,              :to  => :question
    delegate :choices,             :to  => :question
    delegate :enable_check_answer, :to  => :question
    delegate :multi_answer,        :to  => :question
    delegate :show_as_menu,        :to  => :question
    delegate :is_prediction,       :to  => :question

    after_update :send_to_portal

    def self.by_question(q)
      where(:multiple_choice_id => q.id)
    end

    # render the text of the answers
    def answer_texts
      self.answers.map { |a| a.choice }
    end

    def portal_hash
      {
        "type"          => "multiple_choice",
        "question_id"   => multiple_choice_id.to_s,
        "answer_ids"    => answers.map { |a| a.id.to_s },
        "answer_texts"  => answer_texts
      }
    end

    # Expects a parameters hash. Normalizes to allow update_attributes.
    def update_from_form_params(params)
      if params && params[:answers].kind_of?(Array)
        params[:answers] = params[:answers].map { |a| Embeddable::MultipleChoiceChoice.find(a) }
      elsif params && !params[:answers].blank?
        params[:answers] = [Embeddable::MultipleChoiceChoice.find(params[:answers])]
      else
        params[:answers] = []
      end
      return self.update_attributes(params)
    end
  end

end
