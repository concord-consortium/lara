class Api::V1::PluginLearnerStatesController < ApplicationController
  STATUS_OK = 200
  STATUS_ERROR = 500
  STATUS_NOT_FOUND = 404

  private
  def fail(status, message, err)
    render :json => {
        response_type: "ERROR",
        error: "#{message} #{err}"
      }, status: status
  end

  def success(state_data)
    render :json => { state: state_data }, status: STATUS_OK
  end

  def getPluginState
    run_id = params[:run_id]
    plugin_id = params[:plugin_id]
    begin
      run = Run.find(run_id)
      plugin  = Plugin.find(plugin_id)
      @p_state = PluginLearnerState.find_or_create(plugin, run)
    rescue => err
      fail(STATUS_NOT_FOUND, "No state for plugin_id: #{plugin_id}, run_id: #{run_id}", err)
    end
  end

  public
  def load
    getPluginState
    success(@p_state.state)
  end

  def save
    getPluginState
    begin
      state = params[:state]
      puts params
      @p_state.update_attribute(:state, state)
      success(@p_state.reload.state)
    rescue => err
      fail(STATUS_ERROR, "Couldn't update state for PluginLearnerState(#{@p_state.id})", err)
    end
  end

end