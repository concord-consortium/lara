class InteractiveRunStatesController < ApplicationController
  layout false, :except => [:dirty]
  before_filter :set_interactive_run


  def show
    render :json => @run
  end

  def update
    @run.raw_data = params['raw_data']
    if @run.save
      render :json => @run
    else
      render :json => { :success => false }
    end
  end

  private
  def set_interactive_run
    @run = InteractiveRunState.find(params['id'])
  end
end
