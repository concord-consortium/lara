module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    include Answer # Common methods for Answer models

    attr_accessible :answer_text, :run, :question, :is_dirty

    belongs_to :question,
      :class_name => 'Embeddable::OpenResponse',
      :foreign_key => "open_response_id"

    belongs_to :run

    scope :by_question, lambda { |q|
      {:conditions => { :open_response_id => q.id}}
    }

    scope :by_run, lambda { |r|
      {:conditions => { :run_id => r.id }}
    }

    delegate :prompt,  :to  => :question
    delegate :name,    :to  => :question

    after_update :send_to_portal

    def portal_hash
      {
        "type" => "open_response",
        "question_id" => question.id.to_s,
        "answer" => answer_text
      }
    end
  end
end
