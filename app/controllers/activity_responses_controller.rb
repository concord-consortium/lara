class ActivityResponsesController < ApplicationController
  layout false

  def show
    if !params[:id].nil?
      @response = ActivityResponse.find_or_create_by_key_and_activity_id(params[:id], params[:activity_id])
      render :json => @response.to_json
    else
      @activity = LightweightActivity.find(params[:activity_id])
      @reponse = ActivityResponse.create(:activity => @activity)
      # Ask again, this time with an ID
      redirect_to activity_activity_response_path(@response, @activity)
    end
  end

  def update
    # If ID, update
    # If no ID, error
  end
end
