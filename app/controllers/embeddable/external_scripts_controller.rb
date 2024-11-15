class Embeddable::ExternalScriptsController < Embeddable::EmbeddablesController
  before_action :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::ExternalScript.find(params[:id])
  end
end
