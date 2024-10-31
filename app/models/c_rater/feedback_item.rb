class CRater::FeedbackItem < Embeddable::FeedbackItem
  self.table_name = 'c_rater_feedback_items'

  STATUS_REQUESTED = 'requested'
  STATUS_SUCCESS = 'success'
  STATUS_ERROR = 'error'

  # Additional fields:
  # attr_accessible :status, :item_id, :response_info
  serialize :response_info

  def successful?
    status == STATUS_SUCCESS
  end

  def error_msg
    return nil if successful?
    # Reuse existing text column.
    feedback_text
  end
end
