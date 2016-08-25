class InteractiveRunStatesController < ApplicationController
  layout false, :except => [:dirty]
  before_filter :set_interactive_run

  def show
    if is_authorized?("get")
      render :json => @run.to_runtime_json
    end
  end

  def update
    if is_authorized?("update")
      @run.raw_data = params['raw_data']
      @run.learner_url = params['learner_url']
      if @run.save
        render :json => @run.to_runtime_json
      else
        render :json => { :success => false }
      end
    end
  end

  private
  def set_interactive_run
    @run = InteractiveRunState.find_by_key!(params['key'])
  end

  def is_authorized?(action)
    # unowned runs can be read/written by anyone, owned runs only by their owner and admin
    authorized = @run.run.user.nil? || (current_user && ((@run.run.user == current_user) || current_user.admin?))
    if !authorized
      reason = current_user ? "the owner or an admin" : "logged in"
      render :json => { :error => "You are not authorized to #{action} the requested owned interactive run state because you are not #{reason}."}
    end
    authorized
  end
end
