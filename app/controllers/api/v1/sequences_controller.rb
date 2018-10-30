class Api::V1::SequencesController < API::APIController
  def destroy
    begin
      sequence = Sequence.find(params[:id])
      authorize! :destroy, sequence
      Sequence.find(params[:id]).destroy
      render :json => { success: true }
    rescue CanCan::AccessDenied => err
      not_authorized(err.message)
    end
  end
end
