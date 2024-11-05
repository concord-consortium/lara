class AddPromptToChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choice_choices, :prompt, :text
  end
end
