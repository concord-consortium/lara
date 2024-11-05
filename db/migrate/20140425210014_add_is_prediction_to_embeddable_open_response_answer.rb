class AddIsPredictionToEmbeddableOpenResponseAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_open_response_answers, :is_prediction, :boolean, :default => false
  end
end
