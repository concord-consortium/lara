class Embeddable::OpenResponseAnswersController < ApplicationController
  # TODO: ensure the user can change this....
  def update
    answer = Embeddable::OpenResponseAnswer.find(params[:id])
    # FIXME: This succeeds, but doesn't update because the params aren't properly structured
    if answer.update_attributes(params[:embeddable_open_response_answer])
      respond_to do |format|
        format.json { render :json => answer }
      end
    else
      respond_to do |format|
        format.json { render :json => answer.errors }
      end
    end
  end
end
