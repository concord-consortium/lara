class RenameImageQuestionAnswersIndexes < ActiveRecord::Migration[5.1]
  def up
    rename_index :embeddable_image_question_answers, 'index_embeddable_image_question_answers_on_image_question_id', 'index_on_image_question_id'
    rename_index :embeddable_image_question_answers, 'index_multiple_choice_answers_on_run_and_question', 'index_on_run_and_question'
    rename_index :embeddable_image_question_answers, 'index_embeddable_image_question_answers_on_run_id', 'index_on_run_id'
  end

  def down
    rename_index :embeddable_image_question_answers, 'index_on_image_question_id', 'index_embeddable_image_question_answers_on_image_question_id'
    rename_index :embeddable_image_question_answers, 'index_on_run_and_question', 'index_multiple_choice_answers_on_run_and_question'
    rename_index :embeddable_image_question_answers, 'index_on_run_id', 'index_embeddable_image_question_answers_on_run_id'
  end
end
