class GlobalInteractiveStatesController < ApplicationController
  before_action :set_run
  before_action :authorize_run_access

  # POST /runs/:run_id/global_interactive_state
  # Expected parameter: raw_data
  # This action creates a new global interactive state for given run or updates existing one.
  def create
    if @run.global_interactive_state
      @run.global_interactive_state.update_attributes!(raw_data: params[:raw_data])
      head :ok
    else
      GlobalInteractiveState.create!(run_id: @run.id, raw_data: params[:raw_data])
      head :created
    end
  end

  private

  def set_run
    @run = Run.where(key: params[:run_id]).first
  end

  def authorize_run_access
    begin
      authorize!(:access, @run)
    rescue
      head :unauthorized
    end
  end
end
