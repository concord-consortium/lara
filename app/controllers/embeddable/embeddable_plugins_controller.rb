class Embeddable::EmbeddablePluginsController < Embeddable::EmbeddablesController
  before_filter :set_embeddable


  # modified from application_controller.rb `respond_with_edit_form`

  def render_plugin_form(css_class = nil, container_class = nil)
    respond_to do |format|
      format.js do
        render(
          json: {
            html: render_to_string('edit'),
            css_class: css_class,
            container_class: container_class
          },
          content_type: 'text/json'
        )
      end
      format.html { render 'edit', layout: 'minimal' }
    end
  end

  def edit
    # set theme for plugin preview
    current_theme
    render_plugin_form("allow-full-width", "opaque-background")
  end

  private
  def set_embeddable
    @embeddable = Embeddable::EmbeddablePlugin.find(params[:id])
  end
end
