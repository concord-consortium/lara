class AddIsPredictionToEmbeddableMutipleChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choices, :is_prediction, :boolean, :default => false
  end
end
