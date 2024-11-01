class Embeddable::ImageQuestionsController < Embeddable::EmbeddablesController
  before_action :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::ImageQuestion.find(params[:id])
  end
end
