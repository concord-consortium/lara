class AddApprovedScriptAuthoringMetadata < ActiveRecord::Migration[5.1]
  def change
    add_column :approved_scripts, :authoring_metadata, :text
  end
end
