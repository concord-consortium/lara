module Embeddable
  class ImageQuestionAnswer < ApplicationRecord
    include Answer


    belongs_to :question,
      class_name: 'Embeddable::ImageQuestion',
      foreign_key: "image_question_id"

    belongs_to :run

    delegate :drawing_prompt, to: :question
    delegate :is_shutterbug?, to: :question
    delegate :is_drawing?,    to: :question
    delegate :is_upload?,     to: :question
    delegate :interactive,    to: :question

    after_update :send_to_portal
    after_update :propagate_to_collaborators

    def self.by_question(q)
      where(image_question_id: q.id)
    end

    def has_snapshot?
      !image_url.blank?
    end

    def require_image_url
      return true unless is_drawing?
      return !question.bg_url.blank?
    end

    def copy_answer!(another_answer)
      self.update!(
        answer_text: another_answer.answer_text,
        image_url: another_answer.image_url,
        annotated_image_url: another_answer.annotated_image_url,
        annotation: another_answer.annotation,
        is_final: another_answer.is_final
      )
    end

    def portal_hash
      {
        "type" => "image_question",
        "question_id" => image_question_id.to_s,
        "answer" => answer_text,
        "is_final" => is_final,
        "image_url" => annotated_image_url
      }
    end

    def report_service_hash
      {
        id: answer_id,
        type: 'image_question_answer',
        question_id: question.embeddable_id,
        question_type: 'image_question',
        answer: {
          image_url: annotated_image_url,
          text: answer_text
        },
        submitted: is_final
      }
    end

    def answered?
      annotated_image_url.present?
    end
  end
end
