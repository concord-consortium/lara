class Embeddable::ImageQuestionsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::ImageQuestion.find(params[:id])
  end
end
