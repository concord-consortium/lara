class Api::V1::PluginsController < ApplicationController
  STATUS_OK = 200
  STATUS_ERROR = 500
  STATUS_NOT_FOUND = 404
  STATUS_NOT_AUTHORIZED = 403

  private
  def fail(status, message, err)
    render json: {
        response_type: "ERROR",
        error: "#{message} #{err}"
      }, status: status
  end

  def notAuthorized(err)
    fail(
      STATUS_NOT_AUTHORIZED,
      "Not authorized: for user: #{current_user && current_user.id}",
      err
    )
  end

  def render_author_data(plugin)
    render json: { author_data: plugin.author_data }, status: STATUS_OK
  end


  def get_plugin
    plugin_id = params[:plugin_id]
    begin
      plugin = Plugin.find(plugin_id)
    rescue CanCan::AccessDenied => err
      notAuthorized(err)
    rescue => err
      fail(
        STATUS_NOT_FOUND,
        "No plugin for id: #{plugin_id}",
        err
      )
    end
    plugin
  end

  public

  def load_author_data
    plugin = get_plugin
    authorize! :manage, plugin
    render_author_data(plugin)
  end

  def save_author_data
    author_data = params[:author_data]
    plugin = get_plugin
    begin
      authorize! :manage, plugin
      plugin.update_attribute(:author_data, author_data)
      render_author_data(plugin)
    rescue CanCan::AccessDenied => err
      notAuthorized(err)
    rescue => err
      fail(
        STATUS_ERROR,
        "Couldn't update author_data for Plugin(#{plugin.id})",
        err
      )
    end
  end

end