class CRater::FeedbackSubmission < ActiveRecord::Base
  # Provided by student.
  attr_accessible :usefulness_score

  has_many :feedback_items, as: :feedback_submission

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
end
