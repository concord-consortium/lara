class Embeddable::LoggingFeedbacksController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::LoggingFeedback.find(params[:id])
  end
end
