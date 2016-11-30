class RenameSaveStateToEnableLearnerState < ActiveRecord::Migration
  def change
    rename_column :mw_interactives, :save_state, :enable_learner_state
  end
end
