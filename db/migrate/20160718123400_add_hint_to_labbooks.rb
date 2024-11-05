class AddHintToLabbooks < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_labbooks, :hint, :text
  end
end
