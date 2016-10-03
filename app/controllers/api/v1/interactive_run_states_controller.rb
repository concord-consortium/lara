class Api::V1::InteractiveRunStatesController < ApplicationController
  layout false
  before_filter :set_interactive_run

  skip_before_filter :verify_authenticity_token, :only => :update

  def show
    begin
      authorize! :show, @run

      render :json => @run.to_runtime_json
    rescue CanCan::AccessDenied
      authorization_error("get")
    end
  end

  def update
    begin
      authorize! :update, @run

      @run.raw_data = params['raw_data']
      @run.learner_url = params['learner_url']
      if @run.save
        render :json => @run.to_runtime_json
      else
        render :json => { :success => false }
      end
    rescue CanCan::AccessDenied
      authorization_error("update")
    end
  end

  private

  def set_interactive_run
    @run = InteractiveRunState.find_by_key!(params['key'])
  end

  def authorization_error(action)
    reason = current_user ? "the owner or an admin or a collaborator" : "logged in"
    render :json => { :success => false, :message => "You are not authorized to #{action} the requested owned interactive run state because you are not #{reason}."}
  end
end
