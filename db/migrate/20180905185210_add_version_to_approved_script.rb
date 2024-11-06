class AddVersionToApprovedScript < ActiveRecord::Migration
  def change
    add_column :approved_scripts, :version, :decimal, default: 1
  end
end
