class AddVersionToApprovedScript < ActiveRecord::Migration[5.1]
  def change
    add_column :approved_scripts, :version, :decimal, default: 1
  end
end
