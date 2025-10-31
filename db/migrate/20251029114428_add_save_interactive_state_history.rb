class AddSaveInteractiveStateHistory < ActiveRecord::Migration[8.0]
  def change
    add_column :lightweight_activities, :save_interactive_state_history, :boolean, default: false
    add_column :sequences, :save_interactive_state_history, :boolean, default: false

    add_column :library_interactives, :save_interactive_state_history, :boolean, default: false
    add_column :mw_interactives, :save_interactive_state_history, :boolean, default: false

    add_column :managed_interactives, :inherit_save_interactive_state_history, :boolean, default: true
    add_column :managed_interactives, :custom_save_interactive_state_history, :boolean, default: false
  end
end
