class Api::V1::ImportController < API::APIController
  skip_before_action :verify_authenticity_token, only: :import
  def import
    authorize! :create, LightweightActivity
    json_object = JSON.parse request.body.read, symbolize_names: true
    import_result = Import.import(json_object[:import], current_user)
    if import_result[:success]
      url = import_result[:type] === "Sequence" ?
        sequence_url(import_result[:import_item]) :
        activity_url(import_result[:import_item])
      render json: { success: true, url: url }
    else
      raise API::APIError, import_result[:error]
    end
  end
end
