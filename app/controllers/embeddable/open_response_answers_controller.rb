class Embeddable::OpenResponseAnswersController < Embeddable::EmbeddableAnswersController

  @embeddable_type = Embeddable::OpenResponseAnswer

  def update
    respond_to do |format|
      if @answer.update_attributes(params[:embeddable_open_response_answer])
        format.json { render :json => @answer.to_json }
      else
        format.json { render :json => @answer.errors }
      end
    end
  end
end
