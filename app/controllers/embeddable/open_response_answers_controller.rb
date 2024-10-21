class Embeddable::OpenResponseAnswersController < Embeddable::EmbeddableAnswersController

  @embeddable_type = Embeddable::OpenResponseAnswer

  def update_params
    params.require(:embeddable_open_response_answer).permit(
      :answer_text, :run, :question, :is_dirty, :is_final
    )
  end

  def update
    respond_to do |format|
      if @answer.update_attributes(update_params)
        format.json { render :json => @answer.to_json }
      else
        format.json { render :json => @answer.errors }
      end
    end
  end
end
