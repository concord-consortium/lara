class AddAbstractToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :abstract, :text
  end
end
