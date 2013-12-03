class AddDisplayTitleToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :display_title, :string
  end
end
