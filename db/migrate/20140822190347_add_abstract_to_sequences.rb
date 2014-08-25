class AddAbstractToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :abstract, :text
  end
end
