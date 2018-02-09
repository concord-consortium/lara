class Embeddable::ExternalScriptsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::ExternalScript.find(params[:id])
  end
end
