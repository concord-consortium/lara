class AddHideQuestionNumbers < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :hide_question_numbers, :boolean, default: false
    add_column :sequences, :hide_question_numbers, :boolean, default: false
  end
end
