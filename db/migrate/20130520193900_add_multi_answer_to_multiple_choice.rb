class AddMultiAnswerToMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :multi_answer, :boolean, default: false
  end
end
