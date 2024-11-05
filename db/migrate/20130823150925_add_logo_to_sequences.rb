class AddLogoToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :logo, :text
  end
end
