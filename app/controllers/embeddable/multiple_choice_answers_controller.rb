class Embeddable::MultipleChoiceAnswersController < ApplicationController

  def update
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    if answer.update_from_form_params(params['embeddable_multiple_choice_answer'])
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
