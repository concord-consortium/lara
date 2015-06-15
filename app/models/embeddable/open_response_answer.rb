module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    include Answer
    include CRater::FeedbackFunctionality

    attr_accessible :answer_text, :run, :question, :is_dirty, :is_final

    belongs_to :question,
      :class_name => 'Embeddable::OpenResponse',
      :foreign_key => "open_response_id"
    belongs_to :run

    before_save :clear_default_text

    after_update :send_to_portal
    after_update :propagate_to_collaborators

    def self.by_question(q)
      where(:open_response_id => q.id)
    end

    def copy_answer!(another_answer)
      self.update_attributes!(
        answer_text: another_answer.answer_text,
        is_final: another_answer.is_final
      )
    end

    def portal_hash
      {
        "type" => "open_response",
        "question_id" => open_response_id.to_s,
        "answer" => answer_text,
        "is_final" => is_final
      }
    end

    def blank?
      self.answer_text.blank?
    end

    def c_rater_item_settings
      question && question.c_rater_item_settings
    end

    def clear_default_text
      # default_text is delegated to question.default_text so we need to check for an assigned question first
      if question and default_text
        # first time answering?
        if (answer_text_was == nil) && (default_text == answer_text)
          self.answer_text = nil
        end
      end
    end
  end
end
