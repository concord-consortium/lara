class PluginsController < ApplicationController

  private
  def _form(plugin, edit)
    render_to_string('_form', layout: false, locals: { plugin: @plugin, edit: edit })
  end

  public
  def edit
    @plugin = Plugin.find(params[:id])
    respond_with_edit_form("allow-full-width")
  end

  def new
    authorize! :create, Plugin
    @activity = LightweightActivity.find(params[:activity_id])
    @plugin = @activity.plugins.create()
    respond_to do |format|
      format.js {
        render json: {
          html: _form(@plugin, false)
        }
      }
    end
  end

  def update_params
    params.require(:plugin).permit(:description, :author_data, :approved_script_id, :approved_script, :shared_learner_state_key, :component_label)
  end

  # PUT /plugins/1
  def update
    cancel = params[:commit] == "Cancel"
    @params = params
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    if !cancel
      @plugin.update(update_params)
    end

    redirect_to(request.env['HTTP_REFERER'].sub(/\?.+/, ''))
  end

  # DELETE /plugins/1
  def destroy
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    @plugin.destroy
    respond_to do |format|
      format.js do
        # will render destroy.js.erb
      end
    end
  end
end
