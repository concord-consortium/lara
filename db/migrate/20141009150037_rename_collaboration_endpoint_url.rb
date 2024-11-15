class RenameCollaborationEndpointUrl < ActiveRecord::Migration[5.1]
  def change
    rename_column :collaboration_runs, :collaboration_endpoint_url, :collaborators_data_url
  end
end
