class ActivityResponsesController < ApplicationController
  layout false
  before_filter :set_response, :except => [:index]

  def index
    # This is actually a special case of show - create an ActivityResponse and show it
    # - so we'll do that work here and redirect there
    @activity = LightweightActivity.find(params[:activity_id])
    @response = ActivityResponse.create(:activity => @activity, :user => current_user)
    redirect_to activity_activity_response_url(@activity, @response)
  end

  def show
    render :json => @response.to_json
  end

  def update
    # If this response isn't owned by a registered user, and is updated by one, that user now owns it
    if @response.user.blank? && current_user
      @response.user = current_user
    end
    @response.update_attributes(params[:activity_response])
    @response.reload
    render :json => @response.to_json
  end
  
  private
  def set_response
    @response = ActivityResponse.find_or_create_by_key_and_activity_id(params[:id], params[:activity_id])
  end
end
