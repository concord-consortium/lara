class Embeddable::ImageQuestion < ActiveRecord::Base
  attr_accessible :name, :prompt, :bg_source, :bg_url, :drawing_prompt,
    :is_prediction, :give_prediction_feedback, :prediction_feedback

  include Embeddable

  has_many :page_items, :as => :embeddable, :dependent => :destroy
  has_many :interactive_pages, :through => :page_items

  has_many :answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'image_question_id',
    :dependent   => :destroy

  default_value_for :prompt, "why does ..."

  # NOTE: publishing to portal doesn't use this hash. See app/models/lightweight_activity.rb
  # for the hash used in portal publishing.
  def to_hash
    {
      name: name,
      prompt: prompt,
      drawing_prompt: drawing_prompt,
      bg_source: bg_source,
      bg_url: bg_url,
      is_prediction: is_prediction,
      give_prediction_feedback: give_prediction_feedback,
      prediction_feedback: prediction_feedback
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
                              :prediction_feedback])
  end
  
  def self.import(import_hash)
    return self.new(import_hash)
  end
  
  def is_shutterbug?
    bg_source == 'Shutterbug'
  end

  def is_drawing?
    bg_source == 'Drawing'
  end

  def self.name_as_param
    :embeddable_image_question
  end

  def self.display_partial
    :image_question
  end

  def self.human_description
    "Image question"
  end
end
