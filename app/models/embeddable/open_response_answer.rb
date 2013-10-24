module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    include Answer # Common methods for Answer models

    attr_accessible :answer_text, :run, :question, :is_dirty

    belongs_to :question,
      :class_name => 'Embeddable::OpenResponse',
      :foreign_key => "open_response_id"

    belongs_to :run

    delegate :prompt,  :to  => :question
    delegate :name,    :to  => :question

    after_update :send_to_portal

    def by_question(q)
      where(:open_response_id => q.id)
    end

    def portal_hash
      {
        "type" => "open_response",
        "question_id" => open_response_id.to_s,
        "answer" => answer_text
      }
    end
  end
end
