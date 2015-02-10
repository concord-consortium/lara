# Mixin. Expects that target class implements:
#  - answer_text (returns string)
#  - feedback_text (returns string)
#  - score (returns integer, optional)
#  - c_rater_settings (should point to CRaterSettings instance if feedback should be obtained, nil otherwise)

module Embeddable::FeedbackFunctionality
  extend ActiveSupport::Concern

  included do
    has_many :feedback_items, as: :answer, class_name: 'Embeddable::FeedbackItem'
  end

  def save_feedback
    return nil if answer_text.blank? || feedback_text.blank?
    feedback_item = Embeddable::FeedbackItem.new(
      answer_text: answer_text,
      feedback_text: feedback_text
    )
    feedback_item.score = score if self.respond_to?(:score)
    feedback_item.answer = self
    feedback_item.save!
    feedback_item
  end

  def get_saved_feedback
    feedback_items.last
  end
end
