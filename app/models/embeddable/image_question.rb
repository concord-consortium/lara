class Embeddable::ImageQuestion < ActiveRecord::Base
  attr_accessible :name, :prompt
  has_many :page_items, :as => :embeddable, :dependent => :destroy
  has_many :interactive_pages, :through => :page_items

  has_many :answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'image_question_id',
    :dependent   => :destroy

  default_value_for :prompt, "why does ..."

  # TODO: Extract this common method to module
  def activity
    if interactive_pages.length > 0
      if interactive_pages.first.lightweight_activity.present?
        return interactive_pages.first.lightweight_activity
      else
        return nil
      end
    else
      return nil
    end
  end

  def to_hash
    {
      name: name,
      prompt: prompt
    }
  end

  def duplicate
    return Embeddable::ImageQuestion.new(self.to_hash)
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
