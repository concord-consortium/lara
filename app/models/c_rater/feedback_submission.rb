class CRater::FeedbackSubmission < ActiveRecord::Base
  # Provided by student.
  attr_accessible :usefulness_score, :interactive_page, :run

  has_many :feedback_items, as: :feedback_submission
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
end
