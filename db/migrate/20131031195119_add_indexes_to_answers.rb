class AddIndexesToAnswers < ActiveRecord::Migration[5.1]
  def change
    add_index :embeddable_open_response_answers, ['run_id', 'open_response_id'], :name => 'index_open_response_answers_on_run_and_question'
    # add_index :embeddable_multiple_choice_answers, ['run_id', 'multiple_choice_id'], :name => 'index_multiple_choice_answers_on_run_and_question'
    add_index :embeddable_image_question_answers, ['run_id', 'image_question_id'], :name => 'index_multiple_choice_answers_on_run_and_question'
  end
end
