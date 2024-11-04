class Api::V1::SequencesController < API::APIController
  def destroy
    sequence = Sequence.find(params[:id])
    authorize! :destroy, sequence
    sequence.destroy
    render json: { success: true }
  end

  # GET /api/v1/sequences/1.json
  def show
    sequence = Sequence.find(params[:id])
    sequence_json = sequence.export(request.host_with_port)
    render json: sequence_json
  end

  # GET /api/v1/sequences/1/reeport_structure.json
  def report_structure
    sequence = Sequence.find(params[:id])
    self_url = "#{request.protocol}#{request.host_with_port}"
    json = sequence.serialize_for_report_service(self_url).to_json
    render json: json
  end
end
