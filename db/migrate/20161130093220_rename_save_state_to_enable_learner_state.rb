class RenameSaveStateToEnableLearnerState < ActiveRecord::Migration[5.1]
  def change
    rename_column :mw_interactives, :save_state, :enable_learner_state
  end
end
