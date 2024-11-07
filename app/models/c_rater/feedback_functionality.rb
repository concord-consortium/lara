# Mixin. Expects that target class implements:
#  - answer_text (returns string)
#  - c_rater_settings (should point to CRaterSettings instance if feedback should be obtained, nil otherwise)

require_dependency 'c_rater/api_wrapper'

module CRater::FeedbackFunctionality
  extend ActiveSupport::Concern
  include Embeddable::FeedbackFunctionality

  # Overwrite Embeddable::FeedbackFunctionality association:
  included do
    has_many :feedback_items, as: :answer, class_name: 'CRater::FeedbackItem'
  end

  # Overwrite Embeddable::FeedbackFunctionality method:
  def save_feedback
    return nil if answer_text.blank?
    request_c_rater_feedback
  end

  # New methods:
  def c_rater_config
    {
      client_id:    ENV['C_RATER_CLIENT_ID'],
      username:     ENV['C_RATER_USERNAME'],
      password:     ENV['C_RATER_PASSWORD'],
      url:          ENV['C_RATER_URL'],    # optional, APIWrapper will use default URL if not provided.
      fake_service: ENV['C_RATER_FAKE'],   # true here will fake score results (for testing) all other config opts ignored.
      api_key:      ENV['C_RATER_API_KEY'] # optional, some services require it.
    }
  end

  def c_rater_enabled?
    c_rater_configured? && c_rater_item_settings_provided?
  end

  private

  def c_rater_configured?
    config = c_rater_config
    return true if config[:fake_service]
    !!config[:client_id] && !!config[:username] && !!config[:password]
  end

  def c_rater_item_settings_provided?
    !!c_rater_item_settings && !c_rater_item_settings.item_id.blank?
  end

  def find_prev_feedback
    return CRater::FeedbackItem.where({
      answer_type: self.class.name,
      answer_id: self.id,
      answer_text: self.answer_text
    }).first
  end

  def copy_of_feedback(prev_feedback)
    feedback_item = CRater::FeedbackItem.create!({
      status: prev_feedback.status,
      answer: self,
      answer_text: self.answer_text,
      score: prev_feedback.score,
      feedback_text: prev_feedback.feedback_text,
      response_info: prev_feedback.response_info
    })
    return feedback_item
  end

  def request_feedback_from_service(options={})
    feedback_item = CRater::FeedbackItem.new(
      status: CRater::FeedbackItem::STATUS_REQUESTED,
      # Save both answer text and item id to prevent context loss - these values can be changed later by user.
      answer_text: answer_text,
      item_id: c_rater_item_settings.item_id,
      answer: self
    )
    if options[:async]
      feedback_item.save!
      delay.continue_feedback_processing(feedback_item)
    else
      continue_feedback_processing(feedback_item)
    end
    feedback_item
  end

  def request_c_rater_feedback(options = {})
    # Return copy of  existing feedback for the same answer_text:
    found = find_prev_feedback
    return copy_of_feedback(found) if found

    # Return an error feedback item if not configured:
    return not_configured unless c_rater_enabled?

    # Otherwise call out to scoring service:
    return request_feedback_from_service
  end

  def continue_feedback_processing(feedback_item)
    response = issue_c_rater_request(feedback_item)
    if response[:success]
      feedback_item.status = CRater::FeedbackItem::STATUS_SUCCESS
      feedback_item.score = response[:score]
      # score -> text mapping
      score_mapping = c_rater_item_settings.score_mapping
      if score_mapping
        feedback_item.feedback_text = score_mapping.get_feedback_text(response[:score])
      else
        feedback_item.feedback_text = I18n.t('ARG_BLOCK.NO_SCORE_MAPPING', score: response[:score])
      end
    else
      feedback_item.status = CRater::FeedbackItem::STATUS_ERROR
      feedback_item.feedback_text = response[:error]
    end
    feedback_item.response_info = response[:response_info]
    feedback_item.save!
  end

  def issue_c_rater_request(feedback_item)
    config = c_rater_config
    if config[:fake_service]
      return issue_fake_feedback(feedback_item)
    else
      crater = CRater::APIWrapper.new(
        config[:client_id],
        config[:username],
        config[:password],
        config[:url],
        config[:api_key])
      # Use answer.id (as answer class includes this module) as response_id provided to C-Rater.
      return crater.get_feedback(feedback_item.item_id, id, feedback_item.answer_text)
    end
  end

  def issue_fake_feedback(feedback_item)
    {
        success:       true,
        score:         rand(feedback_item.max_score + 1),
        response_info: "provided by fake feedback service"
    }
  end

  def not_configured
    if !c_rater_configured?
      error_msg = I18n.t('ARG_BLOCK.NO_GLOBAL_CONFIG')
    elsif !c_rater_item_settings_provided?
      error_msg = I18n.t('ARG_BLOCK.NO_ITEM_CONFIG')
    end
    CRater::FeedbackItem.create!(
      status: CRater::FeedbackItem::STATUS_ERROR,
      answer_text: answer_text,
      item_id: c_rater_item_settings && c_rater_item_settings.item_id,
      feedback_text: error_msg,
      answer: self
    )
  end
end
