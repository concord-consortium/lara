class Embeddable::OpenResponseAnswersController < ApplicationController

  def update
    answer = Embeddable::OpenResponseAnswer.find(params[:id])
    if answer.update_attributes(params[:embeddable_open_response_answer])
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
