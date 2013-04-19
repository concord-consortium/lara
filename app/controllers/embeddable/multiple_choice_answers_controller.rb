class Embeddable::MultipleChoiceAnswersController < ApplicationController

  # TODO: ensure the user can change this....
  def update
    id     = params[:id]
    values = params['embeddable_multiple_choice_answer']
    binding.pry
    answer = Embeddable::MultipleChoiceAnswer.find(params[:id])
    values = params['embeddable_multiple_choice_answer']
    # TODO: something like this:
    # params = params[:embeddable_multiple_choice_answer]
    # answer.answer_texts = [params['answer_texts']]
    # answer.save
  end

end
