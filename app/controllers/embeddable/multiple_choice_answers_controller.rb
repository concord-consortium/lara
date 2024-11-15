class Embeddable::MultipleChoiceAnswersController < Embeddable::EmbeddableAnswersController

  @embeddable_type = Embeddable::MultipleChoiceAnswer

  def update_params
    params.require(:embeddable_multiple_choice_answer).permit(:answers, :run, :question, :is_dirty, :is_final)
  end

  def update
    respond_to do |format|
      mca_params = update_params
      unless mca_params
        AdminEvent.create(kind: "missing_params", message: "missing embeddable_multiple_choice_answer param in params: #{params}") 
      end
      if @answer.update_from_form_params(mca_params)
        format.json { render json: @answer.to_json }
      else
        format.json { render json: @answer.errors }
      end
    end
  end
end
