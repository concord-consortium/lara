class AddSequenceLayoutOverride < ActiveRecord::Migration
  def change
    add_column :sequences, :layout_override, :integer, default: 0
  end
end
