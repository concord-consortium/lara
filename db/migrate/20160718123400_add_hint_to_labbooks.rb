class AddHintToLabbooks < ActiveRecord::Migration
  def change
    add_column :embeddable_labbooks, :hint, :text
  end
end
