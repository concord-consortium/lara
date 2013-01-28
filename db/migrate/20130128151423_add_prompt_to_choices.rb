class AddPromptToChoices < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choice_choices, :prompt, :text
  end
end
