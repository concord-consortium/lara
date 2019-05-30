class AddApprovedScriptAuthoringMetadata < ActiveRecord::Migration
  def change
    add_column :approved_scripts, :authoring_metadata, :text
  end
end
