class AddIsPredictionToEmbeddableOpenResponse < ActiveRecord::Migration
  def change
    add_column :embeddable_open_responses, :is_prediction, :boolean, default: false
  end
end
