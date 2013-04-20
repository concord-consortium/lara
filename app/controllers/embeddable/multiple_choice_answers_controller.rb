class Embeddable::MultipleChoiceAnswersController < ApplicationController

  # TODO: ensure the user can change this....
  def update
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    # binding.pry
    # FIXME: Below fails because form submits a single "c" rather than the expected array.
    if answer.update_attributes(params['embeddable_multiple_choice_answer'])
      # success
      respond_to do |format|
        format.json { render :json => "OK" }
      end
    else
      respond_to do |format|
        format.json { render :json => answer.errors }
      end
    end
  end

end
