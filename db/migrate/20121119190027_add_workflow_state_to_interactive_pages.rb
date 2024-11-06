class AddWorkflowStateToInteractivePages < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :workflow_state, :string
  end
end
