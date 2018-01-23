class Embeddable::ModelFeedbacksController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::ModelFeedback.find(params[:id])
  end
end
