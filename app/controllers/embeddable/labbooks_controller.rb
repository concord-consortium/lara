class Embeddable::LabbooksController < Embeddable::EmbeddablesController
  before_action :set_embeddable

  private

  def set_embeddable
    @embeddable = Embeddable::Labbook.find(params[:id])
  end
end
