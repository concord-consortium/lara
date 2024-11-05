class AddInheritHideQuestionNumber < ActiveRecord::Migration[5.1]
  def change
    add_column :managed_interactives, :inherit_hide_question_number, :boolean, default: true
    add_column :managed_interactives, :custom_hide_question_number, :boolean, default: false
  end
end
