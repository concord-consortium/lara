class Api::V1::LightweightActivitiesController < API::APIController
  def destroy
    begin
      activity = LightweightActivity.find(params[:id])
      authorize! :destroy, activity
      activity.destroy
      render :json => { success: true }
    rescue CanCan::AccessDenied => err
      not_authorized(err.message)
    end
  end
end
