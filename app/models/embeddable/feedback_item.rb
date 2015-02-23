class Embeddable::FeedbackItem < ActiveRecord::Base
  attr_accessible :answer_id, :answer_type, :answer, :answer_text, :feedback_text, :score

  belongs_to :answer, polymorphic: true
  # Feedback item can be associated (but doesn't have to) with submission action.
  # Such model provides grouping and can store additional information that depends on context.
  belongs_to :feedback_submission, polymorphic: true

  def outdated?
    answer_text != answer.answer_text
  end
end
