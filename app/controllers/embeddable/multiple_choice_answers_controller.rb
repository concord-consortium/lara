class Embeddable::MultipleChoiceAnswersController < ApplicationController

  def update
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    respond_to do |format|
      mca_params = params['embeddable_multiple_choice_answer']
      unless mca_params
        AdminEvent.create(kind: "missing_params", message: "missing embeddable_multiple_choice_answer param in params: #{params}") 
      end
      if answer.update_from_form_params(mca_params)
        format.json { render :json => answer.to_json }
      else
        format.json { render :json => answer.errors }
      end
    end
  end

end
