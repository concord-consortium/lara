class Api::V1::LightweightActivitiesController < Api::ApiController
  def destroy
    activity = LightweightActivity.find(params[:id])
    authorize! :destroy, activity
    activity.destroy
    render json: { success: true }
  end

  # GET /api/v1/activities/1.json
  def show
    activity = LightweightActivity.find(params[:id])
    lightweight_activity_json = activity.export(request.host_with_port).to_json
    render json: lightweight_activity_json
  end

  # GET /api/v1/activities/1/report_structure.json
  def report_structure
    activity = LightweightActivity.find(params[:id])
    self_url = "#{request.protocol}#{request.host_with_port}"
    json = activity.serialize_for_report_service(self_url).to_json
    render json: json
  end
end
