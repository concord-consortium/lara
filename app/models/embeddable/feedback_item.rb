class Embeddable::FeedbackItem < ActiveRecord::Base
  attr_accessible :answer_id, :answer_type, :answer_text, :feedback_text

  belongs_to :answer, polymorphic: true

  def outdated?
    answer_text != answer.answer_text
  end
end
