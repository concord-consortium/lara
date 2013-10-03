class Embeddable::MultipleChoiceAnswersController < ApplicationController

  def update
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    respond_to do |format|
      if answer.update_from_form_params(params['embeddable_multiple_choice_answer'])
        format.json { render :json => answer.to_json }
      else
        format.json { render :json => answer.errors }
      end
    end
  end

end
