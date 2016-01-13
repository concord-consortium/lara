class CRater::FeedbackSubmission < ActiveRecord::Base
  # Provided by student.
  attr_accessible :usefulness_score, :interactive_page, :run

  has_many :c_rater_feedback_items, as: :feedback_submission, class_name: 'CRater::FeedbackItem'
  has_many :embeddable_feedback_items, as: :feedback_submission, class_name: 'Embeddable::FeedbackItem'
  belongs_to :interactive_page
  belongs_to :run

  def self.usefulness_score_names
    {
      0 => I18n.t('ARG_BLOCK.USEFUL_0'),
      1 => I18n.t('ARG_BLOCK.USEFUL_1'),
      2 => I18n.t('ARG_BLOCK.USEFUL_2')
    }
  end

  def usefulness_score_name
    self.class.usefulness_score_names[usefulness_score]
  end

  def feedback_items
    c_rater_feedback_items + embeddable_feedback_items
  end
end
