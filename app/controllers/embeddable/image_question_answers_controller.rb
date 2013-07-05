class Embeddable::ImageQuestionAnswersController < ApplicationController
  def update
    answer = Embeddable::ImageQuestionAnswer.find(params[:id])
    if answer.update_attributes(params[:embeddable_image_question_answer])
      respond_to do |format|
        format.json { render :json => answer.to_json }
      end
    else
      respond_to do |format|
        format.json { render :json => answer.errors }
      end
    end
  end


end
