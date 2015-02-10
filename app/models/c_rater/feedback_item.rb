class CRater::FeedbackItem < ActiveRecord::Base
  attr_accessible :answer_id, :answer_type, :answer_text, :item_id, :status, :score, :feedback_text, :response_info
  serialize :response_info

  belongs_to :answer, polymorphic: true
end
