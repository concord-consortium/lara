class AddWorkflowStateToInteractivePages < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :workflow_state, :string
  end
end
