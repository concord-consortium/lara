class InteractiveRunStatesController < ApplicationController
  layout false, :except => [:dirty]
  before_filter :set_interactive_run


  def show
    render :json => @run.to_runtime_json
  end

  def update
    @run.raw_data = params['raw_data']
    @run.learner_url = params['learner_url']
    if @run.save
      render :json => @run.to_runtime_json
    else
      render :json => { :success => false }
    end
  end

  private
  def set_interactive_run
    @run = InteractiveRunState.find(params['id'])
  end
end
