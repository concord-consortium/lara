class EnableCheckAnswerInMultipleChoice < ActiveRecord::Migration
  def up
    add_column :embeddable_multiple_choices, :enable_check_answer, :boolean, default: true
  end

  def down
    remove_column :embeddable_multiple_choices, :enable_check_answer
  end
end
