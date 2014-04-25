class AddIsPredictionToEmbeddableOpenResponseAnswer < ActiveRecord::Migration
  def change
    add_column :embeddable_open_response_answers, :is_prediction, :boolean, :default => false
  end
end
