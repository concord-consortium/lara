module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    include Answer # Common methods for Answer models
    include FeedbackFunctionality

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

    delegate :choices,             :to  => :question
    delegate :enable_check_answer, :to  => :question
    delegate :multi_answer,        :to  => :question
    delegate :show_as_menu,        :to  => :question
    delegate :is_likert,           :to  => :question
    delegate :layout,              :to  => :question

    after_update :send_to_portal
    after_update :propagate_to_collaborators

    def self.by_question(q)
      where(:multiple_choice_id => q.id)
    end

    # render the text of the answers
    def answer_texts
      self.answers.map { |a| a.choice }
    end

    # Required by Embeddable::FeedbackFunctionality
    def answer_text
      answer_texts.join(';')
    end

    # Required by Embeddable::FeedbackFunctionality
    def score
      actual_correct     = choices.count { |c| c.is_correct }
      selected_correct   = answers.count { |a| a.is_correct }
      selected_incorrect = answers.count { |a| !a.is_correct }
      if selected_correct == actual_correct && selected_incorrect == 0
        10 # fully correct answer
      elsif selected_correct > 0
        5 # some correct answers selected
      else
        0 # no correct answers selected
      end
    end

    # Required by Embeddable::FeedbackFunctionality
    def feedback_text
      return nil if answers.length == 0
      answers.map { |a| a.prompt }.join(';')
    end

    def copy_answer!(another_answer)
      self.transaction do
        self.answers = another_answer.answers
        self.update_attributes!(is_final: another_answer.is_final)
      end
    end

    def portal_hash
      {
        "type"          => "multiple_choice",
        "question_id"   => multiple_choice_id.to_s,
        "answer_ids"    => answers.map { |a| a.id.to_s },
        "answer_texts"  => answer_texts,
        "is_final"      => is_final
      }
    end

    # Expects a parameters hash. Normalizes to allow update_attributes.
    def update_from_form_params(params)
      if params && params[:answers].kind_of?(Array)
        params[:answers] = params[:answers].map { |a| Embeddable::MultipleChoiceChoice.find(a) }
      elsif params && !params[:answers].blank?
        params[:answers] = [Embeddable::MultipleChoiceChoice.find(params[:answers])]
      else
        params[:answers] = [] if params # Silence errors about this, we catch them in the controller now
      end
      return self.update_attributes(params)
    end

    def blank?
      self.answers.size == 0
    end
  end

end
