class Embeddable::XhtmlsController < Embeddable::EmbeddablesController
  before_action :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::Xhtml.find(params[:id])
  end
end
