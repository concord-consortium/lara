class AddHintToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_open_responses, :hint, :text
    add_column :embeddable_multiple_choices, :hint, :text
    add_column :embeddable_image_questions, :hint, :text
  end
end
