class Embeddable::ImageQuestion < ActiveRecord::Base
  attr_accessible :name, :prompt, :hint, :bg_source, :bg_url, :drawing_prompt,
    :is_prediction, :give_prediction_feedback, :prediction_feedback, :is_hidden

  include Embeddable

  has_many :page_items, :as => :embeddable, :dependent => :destroy
  has_many :interactive_pages, :through => :page_items

  has_many :answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'image_question_id',
    :dependent   => :destroy

  has_one :tracked_question, :as => :question, :dependent => :delete
  has_one :question_tracker, :through => :tracked_question
  has_one :master_for_tracker, :class_name => 'QuestionTracker', :as => :master_question

  default_value_for :prompt, "why does ..."

  def interactive
    # Return first interactive available on the page (note that in practice it's impossible that this model has more
    # than one page, even though it's many-to-many association).
    # In the future we can let authors explicitly select which interactive an image question is connected to.
    page = interactive_pages.first
    page && page.visible_interactives.first
  end

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
      hint: hint
    }
  end

  def portal_hash
    {
      type: "image_question",
      id: id,
      prompt: prompt,
      drawing_prompt: drawing_prompt,
      is_required: is_prediction
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

  def page_section
    # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
    page_items.count > 0 && page_items.first.section
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
