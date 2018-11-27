class Api::V1::ImportController < API::APIController
  def import
    authorize! :create, LightweightActivity
    import_result = Import.import(params[:import], current_user)
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
