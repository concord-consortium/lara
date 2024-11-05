class AddDisplayTitleToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :display_title, :string
  end
end
