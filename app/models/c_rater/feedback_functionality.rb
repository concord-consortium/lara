# Mixin. Expects that target class implements:
#  - id
#  - answer_text (returns string)
#  - c_rater_settings (should point to CRaterSettings instance if feedback should be obtained, nil otherwise)

# Each time an instance is updated, new C-Rater feedback will be obtained.

module CRater::FeedbackFunctionality
  extend ActiveSupport::Concern

  included do
    has_many :c_rater_feedback_items, as: :answer, class_name: 'CRater::FeedbackItem'
  end

  def c_rater_config
    {
      client_id: ENV['C_RATER_CLIENT_ID'],
      username:  ENV['C_RATER_USERNAME'],
      password:  ENV['C_RATER_PASSWORD'],
      url:       ENV['C_RATER_URL'] # optional, APIWrapper will use default URL if not provided.
    }
  end

  def c_rater_enabled?
    !!c_rater_configured? && !!c_rater_settings && !!c_rater_settings.item_id
  end

  def get_c_rater_feedback
    return unless c_rater_enabled?
    feedback = CRater::FeedbackItem.new(
      status: 'requested',
      # Save both answer text and item id to prevent context loss - these values can be changed later by user.
      answer_text: answer_text,
      item_id: c_rater_settings.item_id
    )
    feedback.answer = self
    feedback.save!
    response = request_feedback
    if response[:success]
      feedback.status = 'success'
      feedback.score = response[:score]
      # TODO: score -> text mapping
      # feedback.feedback_text = ...
    else
      feedback.status = 'error'
    end
    feedback.response_info = response[:response_info]
    feedback.save!
  end
  handle_asynchronously :get_c_rater_feedback

  private

  def c_rater_configured?
    config = c_rater_config
    !!config[:client_id] && !!config[:username] && !!config[:password]
  end

  def request_feedback
    config = c_rater_config
    crater = CRater::APIWrapper.new(config[:client_id], config[:username], config[:password], config[:url])
    item_id = c_rater_settings.item_id
    # Use answer.id (as answer class includes this module) as response_id provided to C-Rater.
    crater.get_feedback(item_id, id, answer_text)
  end
end
