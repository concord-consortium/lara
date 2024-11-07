class AddClickToPlayPromptToMwInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :click_to_play_prompt, :string
  end
end
