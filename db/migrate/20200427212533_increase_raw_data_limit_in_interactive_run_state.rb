class IncreaseRawDataLimitInInteractiveRunState < ActiveRecord::Migration[5.1]
  def up
      change_column :interactive_run_states, :raw_data, :text, limit: 16.megabytes - 1
  end
  def down
      change_column :interactive_run_states, :raw_data, :text
  end
end
