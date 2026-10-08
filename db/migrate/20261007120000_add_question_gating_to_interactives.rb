class AddQuestionGatingToInteractives < ActiveRecord::Migration[8.0]
  def change
    [:mw_interactives, :managed_interactives].each do |table|
      add_column table, :question_gating, :string, null: false, default: "none"
      add_column table, :question_gating_locked_text, :text
      add_column table, :question_gating_unlocked_text, :text
    end
  end
end
