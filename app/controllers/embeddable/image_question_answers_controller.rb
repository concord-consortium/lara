class Embeddable::ImageQuestionAnswersController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ERB::Util

  def update
    answer = Embeddable::ImageQuestionAnswer.find(params[:id])
    respond_to do |format|
      format.json do
        if answer.update_attributes(params[:embeddable_image_question_answer])
          answer_hash = answer.portal_hash
          # this 'formatting' is duplicated in image_question_answers/_lightweight.html.haml
          answer_hash['answer_html'] = simple_format h(truncate(answer.answer_text, length:140))
          render :json => answer_hash.to_json
        else
          render :json => answer.errors
        end
      end
    end
  end


end
