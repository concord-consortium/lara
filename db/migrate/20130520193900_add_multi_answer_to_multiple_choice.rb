class AddMultiAnswerToMultipleChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choices, :multi_answer, :boolean, default: false
  end
end
