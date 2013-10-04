module Embeddable
  class ImageQuestionAnswer < ActiveRecord::Base
    include Answer

    attr_accessible :answer_text, :image_url, :run, :question, :annotation, :annotated_image_url, :is_dirty

    belongs_to :question,
      :class_name => 'Embeddable::ImageQuestion',
      :foreign_key => "image_question_id"

    belongs_to :run

    scope :by_question, lambda { |q|
      {:conditions => { :image_question_id => q.id}}
    }

    scope :by_run, lambda { |r|
      {:conditions => { :run_id => r.id }}
    }

    delegate :prompt,  :to  => :question
    delegate :name,    :to  => :question

    after_update :queue_for_portal

    def has_snapshot?
      !image_url.blank?
    end

    def portal_hash
      {
        "type" => "image_question",
        "question_id" => question.id.to_s,
        "answer" => answer_text,
        "image_url" => annotated_image_url || image_url,
        "annotation" => annotation
      }
    end
  end
end
