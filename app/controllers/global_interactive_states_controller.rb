class GlobalInteractiveStatesController < ApplicationController
  before_filter :set_run

  # POST /runs/:run_id/global_interactive_state
  # Expected parameter: raw_data
  # This action creates a new global interactive state for given run or updates existing one.
  def create
    return json_error('unauthorized') unless auth

    if @run.global_interactive_state
      @run.global_interactive_state.update_attributes!(raw_data: params[:raw_data])
      render nothing: true, status: 200
    else
      GlobalInteractiveState.create!(run_id: @run.id, raw_data: params[:raw_data])
      render nothing: true, status: 201
    end
  end

  private

  def set_run
    @run = Run.where(key: params[:run_id]).first
  end

  def auth
    @run.user == current_user
  end
end
