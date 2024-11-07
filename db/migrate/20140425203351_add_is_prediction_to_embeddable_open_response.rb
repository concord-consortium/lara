class AddIsPredictionToEmbeddableOpenResponse < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_open_responses, :is_prediction, :boolean, default: false
  end
end
