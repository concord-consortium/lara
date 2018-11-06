class Api::V1::SequencesController < API::APIController
  def destroy
    sequence = Sequence.find(params[:id])
    authorize! :destroy, sequence
    Sequence.find(params[:id]).destroy
    render :json => { success: true }
  end
end
