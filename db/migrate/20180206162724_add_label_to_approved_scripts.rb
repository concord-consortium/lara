class AddLabelToApprovedScripts < ActiveRecord::Migration[5.1]
  def change
    add_column :approved_scripts, :label, :string
  end
end
