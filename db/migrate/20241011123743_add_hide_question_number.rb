class AddHideQuestionNumber < ActiveRecord::Migration
  def change
    add_column :library_interactives, :hide_question_number, :boolean, default: false
    add_column :mw_interactives, :hide_question_number, :boolean, default: false
  end
end
