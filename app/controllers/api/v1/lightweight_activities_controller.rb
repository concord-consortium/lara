class Api::V1::LightweightActivitiesController < API::APIController
  def destroy
    activity = LightweightActivity.find(params[:id])
    authorize! :destroy, activity
    activity.destroy
    render :json => { success: true }
  end

  # GET /api/v1/activities/1.json
  def show
    activity = LightweightActivity.find(params[:id])
    lightweight_activity_json = activity.export.to_json
    respond_to do |format|
      format.html # show.html.html.haml
      format.json { render json: lightweight_activity_json }
    end
  end
end
