class RunsController < ApplicationController
  layout false
  before_filter :set_run, :except => [:index]

  def index
    # This is actually a special case of show - create an Run and show it
    # - so we'll do that work here and redirect there
    @activity = LightweightActivity.find(params[:activity_id])
    @run = Run.create(:activity => @activity, :user => current_user)
    redirect_to activity_run_url(@activity, @run)
  end

  def show
    render :json => @run.to_json(:methods => [:last_page, :storage_keys, :responses])
  end

  # we dont bulk-update a run currently. We might want to later.
  # https://gist.github.com/knowuh/590e61ce6ea4d3d3f2eb
  # If this run isn't owned by a registered user, and is updated by one, that user now owns it
  # def update
  # end

  private
  def set_run
    @run = Run.find_or_create_by_key_and_activity_id(params[:id], params[:activity_id])
  end
end
