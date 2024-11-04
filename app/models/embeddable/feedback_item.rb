class Embeddable::FeedbackItem < ApplicationRecord

  belongs_to :answer, polymorphic: true
  # Feedback item can be associated (but doesn't have to) with submission action.
  # Such model provides grouping and can store additional information that depends on context.
  belongs_to :feedback_submission, polymorphic: true
  delegate :max_score, to: :answer, allow_nil: true

  def outdated?
    answer_text != answer.answer_text
  end

  def error?
    score.nil?
  end
end
