class Embeddable::EmbeddablePluginsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  private
  def set_embeddable
    @embeddable = Embeddable::EmbeddablePlugin.find(params[:id])
  end
end
