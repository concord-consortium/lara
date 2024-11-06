class RenameCollaborationEndpointUrl < ActiveRecord::Migration
  def change
    rename_column :collaboration_runs, :collaboration_endpoint_url, :collaborators_data_url
  end
end
