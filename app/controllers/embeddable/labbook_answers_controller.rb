class Embeddable::LabbookAnswersController < ApplicationController

  def update
    answer = Embeddable::LabbookAnswer.find(params[:id])
    # There is nothing to update, all the data is stored in external service. Update timestamps to trigger
    # after_update callbacks (Portal reporting and run with collaborators).
    answer.mark_updated
    render nothing: true, status: 200
  end
end
