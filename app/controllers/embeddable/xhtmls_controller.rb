class Embeddable::XhtmlsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::Xhtml.find(params[:id])
  end
end
