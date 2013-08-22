module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    attr_accessible :answer_text, :run, :question

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

    def question_index
      if self.run && self.run.activity
        self.run.activity.questions.index(self.question) + 1
      else
        nil
      end
    end

    def prompt_no_itals
      parsed_prompt = Nokogiri::HTML::DocumentFragment.parse(prompt)
      itals = parsed_prompt.at_css "i"
      if itals
        itals.content = nil
      end
      parsed_prompt.to_html
    end

    def portal_hash
      {
        "type" => "open_response",
        "question_id" => question.id.to_s,
        "answer" => answer_text
      }
    end

    def send_to_portal
      run.send_to_portal(self) if run
    end

    def to_json
      portal_hash.to_json
    end
  end
end
