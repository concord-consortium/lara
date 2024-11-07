class Embeddable::OpenResponsesController < Embeddable::EmbeddablesController
  before_action :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::OpenResponse.find(params[:id])
  end
end
