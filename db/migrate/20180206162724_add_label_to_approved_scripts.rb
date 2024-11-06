class AddLabelToApprovedScripts < ActiveRecord::Migration
  def change
    add_column :approved_scripts, :label, :string
  end
end
