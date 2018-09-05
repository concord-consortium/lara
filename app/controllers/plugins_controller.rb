class PluginsController < ApplicationController

  private
  def _list_plugins(plugin)
    all_plugins = plugin.plugin_scope.reload.plugins
    render_to_string('_list_plugins', layout: false, locals: {plugins: all_plugins})
  end

  def _form(plugin)
    render_to_string('_form', layout: false, locals: { plugin: @plugin })
  end

  public
  def edit
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    respond_to do |format|
      format.js {
        render :json => {
          html: _form(@plugin)
        }
      }
    end
  end

  def new
    authorize! :create, Plugin
    @activity = LightweightActivity.find(params[:activity_id])
    @plugin = @activity.plugins.create()
    respond_to do |format|
      format.js {
        render :json => {
          html: _form(@plugin)
        }
      }
    end
  end

  # PUT /plugins/1
  def update
    cancel = params[:commit] == "Cancel"
    @params = params
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    if !cancel
      @plugin.update_attributes(params['plugin'])
      @plugin.reload
    end

    @plugin_list = _list_plugins(@plugin)
    respond_to do |format|
      format.js do
        # will render update.js.erb
      end
    end
  end

  # DELETE /plugins/1
  def destroy
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    @plugin.destroy
    @plugin_list = _list_plugins(@plugin)
    respond_to do |format|
      format.js do
        # will render destroy.js.erb
      end
    end
  end
end
