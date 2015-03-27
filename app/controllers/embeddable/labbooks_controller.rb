class Embeddable::LabbooksController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private

  def set_embeddable
    @embeddable = Embeddable::Labbook.find(params[:id])
  end
end
