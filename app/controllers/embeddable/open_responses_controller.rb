class Embeddable::OpenResponsesController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::OpenResponse.find(params[:id])
  end
end
