class Api::V1::LightweightActivitiesController < API::APIController
  def destroy
    activity = LightweightActivity.find(params[:id])
    authorize! :destroy, activity
    activity.destroy
    render :json => { success: true }
  end
end
