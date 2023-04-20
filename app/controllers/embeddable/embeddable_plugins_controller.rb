class Embeddable::EmbeddablePluginsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable

  def edit
    respond_with_edit_form("allow-full-width", "opaque-background")
  end

  private
  def set_embeddable
    @embeddable = Embeddable::EmbeddablePlugin.find(params[:id])
  end
end
