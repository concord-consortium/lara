class AddSequenceLayoutOverride < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :layout_override, :integer, default: 0
  end
end
