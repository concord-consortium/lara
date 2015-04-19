class Embeddable::LabbookAnswersController < Embeddable::EmbeddableAnswersController

  @embeddable_type = Embeddable::LabbookAnswer

  def update
    # There is nothing to update, all the data is stored in external service. Update timestamps to trigger
    # after_update callbacks (Portal reporting and run with collaborators).
    @answer.mark_updated
    render nothing: true, status: 200
  end
end
