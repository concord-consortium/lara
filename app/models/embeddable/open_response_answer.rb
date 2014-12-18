module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    include Answer # Common methods for Answer models

    attr_accessible :answer_text, :run, :question, :is_dirty, :is_final

    belongs_to :question,
      :class_name => 'Embeddable::OpenResponse',
      :foreign_key => "open_response_id"

    belongs_to :run

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
  end
end
