class Embeddable::ImageQuestionAnswersController < Embeddable::EmbeddableAnswersController
  include ActionView::Helpers::TextHelper
  include ERB::Util

  @embeddable_type = Embeddable::ImageQuestionAnswer

  def update_params
    params.require(:embeddable_image_question_answer).permit(
      :answer_text, :image_url, :run, :question, :annotation,
      :annotated_image_url, :is_dirty, :is_final
    )
  end

  def update
    respond_to do |format|
      format.json do
        if @answer.update_attributes(update_params)
          answer_hash = @answer.portal_hash
          # this 'formatting' is duplicated in image_question_answers/_lightweight.html.haml
          answer_hash['answer_html'] = simple_format h(truncate(@answer.answer_text, length:140))
          render json: answer_hash.to_json
        else
          render json: @answer.errors
        end
      end
    end
  end

end
