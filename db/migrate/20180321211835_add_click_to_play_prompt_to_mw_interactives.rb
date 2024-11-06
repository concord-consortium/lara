class AddClickToPlayPromptToMwInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :click_to_play_prompt, :string
  end
end
