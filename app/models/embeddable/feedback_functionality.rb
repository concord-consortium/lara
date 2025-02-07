# Mixin. Expects that target class implements:
#  - answer_text (returns string)
#  - feedback_text (returns string)
#  - score (returns integer, optional)

module Embeddable::FeedbackFunctionality
  extend ActiveSupport::Concern

  included do
    has_many :feedback_items, as: :answer, class_name: 'Embeddable::FeedbackItem'
  end

  def save_feedback
    return nil if answer_text.blank?
    feedback_item = Embeddable::FeedbackItem.new(
      answer_text: answer_text,
      feedback_text: feedback_text
    )
    if self.respond_to?(:score)
      feedback_item.score = score
    end
    feedback_item.answer = self
    feedback_item.save!
    feedback_item
  end

  def get_saved_feedback
    feedback_items.last
  end

  def max_score
    if self.question && self.question.respond_to?(:max_score)
      self.question.max_score
    else
      nil
    end
  end

end
