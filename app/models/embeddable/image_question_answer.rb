module Embeddable
  class ImageQuestionAnswer < ActiveRecord::Base
    include Answer

    attr_accessible :answer_text, :image_url, :run, :question, :annotation, :annotated_image_url, :is_dirty

    belongs_to :question,
      :class_name => 'Embeddable::ImageQuestion',
      :foreign_key => "image_question_id"

    belongs_to :run

    delegate :prompt,         :to => :question
    delegate :drawing_prompt, :to => :question
    delegate :name,           :to => :question
    delegate :is_shutterbug?, :to => :question
    delegate :is_drawing?,    :to => :question

    after_update :send_to_portal

    def self.by_question(q)
      where(:image_question_id => q.id)
    end

    def has_snapshot?
      !image_url.blank?
    end

    def portal_hash
      {
        "type" => "image_question",
        "question_id" => image_question_id.to_s,
        "answer" => answer_text,
        "image_url" => annotated_image_url || image_url,
        "annotation" => annotation
      }
    end
  end
end
