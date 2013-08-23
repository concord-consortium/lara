class AddLogoToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :logo, :text
  end
end
