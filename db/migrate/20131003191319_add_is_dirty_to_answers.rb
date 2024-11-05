class AddIsDirtyToAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choice_answers, :is_dirty, :boolean, default: false
    add_column :embeddable_open_response_answers, :is_dirty, :boolean, default: false
    add_column :embeddable_image_question_answers, :is_dirty, :boolean, default: false
  end
end
