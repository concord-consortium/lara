class Embeddable::ImageQuestion < ApplicationRecord
  include Embeddable
  include AttachedToInteractive

  has_many :page_items, as: :embeddable, dependent: :destroy
  has_many :sections, through: :page_items
  has_many :interactive_pages, through: :sections
  has_many :embeddable_plugins, as: :embeddable
  has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref

  has_many :answers,
    class_name: 'Embeddable::ImageQuestionAnswer',
    foreign_key: 'image_question_id',
    dependent: :destroy

  default_value_for :prompt, "why does ..."

  # NOTE: publishing to portal doesn't use this hash. portal_hash is used instead
  def to_hash
    {
      name: name,
      prompt: prompt,
      drawing_prompt: drawing_prompt,
      bg_source: bg_source,
      bg_url: bg_url,
      is_prediction: is_prediction,
      give_prediction_feedback: give_prediction_feedback,
      prediction_feedback: prediction_feedback,
      is_hidden: is_hidden,
      is_half_width: is_half_width,
      hint: hint
    }
  end

  def portal_hash
    {
      type: "image_question",
      id: id,
      prompt: prompt,
      drawing_prompt: drawing_prompt,
      is_required: is_prediction,
    }
  end

  def report_service_hash
    {
      type: 'image_question',
      id: embeddable_id,
      prompt: prompt,
      drawing_prompt: drawing_prompt,
      question_number: index_in_activity,
      required: is_prediction
    }
  end

  def duplicate
    return Embeddable::ImageQuestion.new(self.to_hash)
  end

  def export
    return self.as_json(only:[:name,
                              :prompt,
                              :drawing_prompt,
                              :bg_source,
                              :bg_url,
                              :is_prediction,
                              :give_prediction_feedback,
                              :prediction_feedback,
                              :is_hidden,
                              :is_half_width,
                              :hint])
  end

  def self.import(import_hash)
    new_ques = self.new(import_hash)
    new_ques.prompt = "" unless import_hash[:prompt]
    new_ques.save!
    return new_ques
  end

  def is_shutterbug?
    bg_source == 'Shutterbug'
  end

  def is_drawing?
    bg_source == 'Drawing'
  end

  def is_upload?
    bg_source == 'Upload'
  end

  def reportable?
    true
  end

  def configuration_error
    return I18n.t('SNAPSHOT_WITHOUT_INTERACTIVE') if is_shutterbug? && interactive.nil?
    nil
  end

  def self.name_as_param
    :embeddable_image_question
  end

  def self.display_partial
    :image_question
  end
end
