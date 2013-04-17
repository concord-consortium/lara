module Embeddable
  class OpenResponseAnswer < ActiveRecord::Base
    attr_accessible :answer_text, :open_response, :run_id

    belongs_to :question,
      :class_name => 'Embeddable::OpenResponse',
      :foreign_key => "open_response_id"
    belongs_to :run
  end
end
