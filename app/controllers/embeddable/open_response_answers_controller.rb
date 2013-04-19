class Embeddable::OpenResponseAnswersController < ApplicationController
  # TODO: ensure the user can change this....
  def update
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    # TODO: something like this:
    # params = params[:embeddable_multiple_choice_answer]
    # answer.answer_texts = [params['answer_texts']]
    # answer.save
  end
end
