class Api::V1::SequencesController < API::APIController
  def destroy
    sequence = Sequence.find(params[:id])
    authorize! :destroy, sequence
    sequence.destroy
    render :json => { success: true }
  end

  # GET /api/v1/sequences/1.json
  def show
    sequence = Sequence.find(params[:id])
    sequence_json = sequence.export
    render json: sequence_json
  end
end
